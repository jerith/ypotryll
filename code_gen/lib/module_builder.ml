open Amqp_spec

let fmt_in_vbox ppf offset start fmt_func finish =
  let open Format in
  pp_open_vbox ppf offset;
  fprintf ppf (Scanf.format_from_string start "");
  fmt_func ppf;
  (match finish with
   | Some finish -> pp_print_break ppf 0 (-offset); pp_print_string ppf finish
   | None -> ());
  pp_close_box ppf ()

let fmt_list_in_vbox ppf start finish fmt_item list =
  let fmt_list ppf =
    List.iter (fun item -> Format.pp_print_cut ppf (); fmt_item ppf item) list
  in
  fmt_in_vbox ppf 2 start fmt_list (Some finish)

let fmt_function ppf start fmt_func =
  fmt_in_vbox ppf 2 start fmt_func None

let fmt_module ppf module_name fmt_func =
  let start = "module " ^ module_name ^ " = struct" in
  fmt_in_vbox ppf 2 start fmt_func (Some "end")

let fmt_module_type ppf module_name fmt_func =
  let start = "module type " ^ module_name ^ " = sig" in
  fmt_in_vbox ppf 2 start fmt_func (Some "end")

let name_to_ocaml = String.map (function
    | '-' -> '_'
    | c -> c
  )

let map_methods spec func =
  List.rev (List.fold_left (fun acc cls -> List.fold_left (fun acc meth ->
      func (spec, cls, meth) :: acc
    ) acc cls.Class.methods) [] spec.Spec.classes)

let iter_methods spec func =
  List.iter (fun cls -> List.iter (fun meth ->
      func (spec, cls, meth)
    ) cls.Class.methods) spec.Spec.classes

let make_method_name cls meth =
  name_to_ocaml (Printf.sprintf "%s_%s" cls.Class.name meth.Method.name)

let make_field_name field =
  match name_to_ocaml field.Field.name with
  | "type" -> "type_"
  | name -> name

let rec get_constant_value name = function
  | [] -> failwith ("Undefined constant: " ^ name)
  | const :: constants ->
    if const.Constant.name = name
    then const.Constant.value
    else get_constant_value name constants

let ocaml_type_from_amqp_type = function
  | "bit" -> "bool"
  | "long" -> "int"
  | "longlong" -> "int"
  | "longstr" -> "string"
  | "octet" -> "int"
  | "short" -> "int"
  | "shortstr" -> "string"
  | "table" -> "Amqp_table.table"
  | "timestamp" -> "int"
  | data_type -> failwith ("Unexpected AMQP field type: " ^ data_type)

let amqp_field_type_from_type = function
  | "octet" -> "Octet"
  | "short" -> "Short"
  | "long" -> "Long"
  | "longlong" -> "Longlong"
  | "bit" -> "Bit"
  | "shortstr" -> "Shortstring"
  | "longstr" -> "Longstring"
  | "timestamp" -> "Timestamp"
  | "table" -> "Table"
  | data_type -> failwith ("Unexpected AMQP field type: " ^ data_type)

let reserved_value_for_ocaml_type = function
  | "bool" -> Printf.sprintf "%B" false
  | "int" -> Printf.sprintf "%d" 0
  | "string" -> Printf.sprintf "%S" ""
  | "Amqp_table.table" -> "[]"
  | ocaml_type -> failwith ("Unexpected OCaml type: " ^ ocaml_type)

let types_from_domain spec domain_name =
  let rec inner = function
    | [] -> failwith ("Domain not found: " ^ domain_name)
    | domain :: domains ->
      if domain.Domain.name <> domain_name
      then inner domains
      else (ocaml_type_from_amqp_type domain.Domain.data_type, domain.Domain.data_type)
  in
  inner spec.Spec.domains

let types_from_field spec field =
  let { Field.reserved; Field.domain; Field.data_type } = field in
  let domain, (ocaml_type, amqp_type) = match reserved, domain, data_type with
    | true, None, Some data_type ->
      ("reserved", (ocaml_type_from_amqp_type data_type, data_type))
    | false, Some domain, None ->
      (domain, types_from_domain spec domain)
    | _ -> assert false
  in
  (ocaml_type, domain ^ " : " ^ amqp_type, amqp_field_type_from_type amqp_type)


module Method_module = struct

  (* stuff for building method modules *)

  type t = {
    name : string;
    text : string;
  }

  let fmt_method_constants ppf (cls, meth) =
    Format.fprintf ppf "@[<v>let %s = %d@;let %s = %d@;let %s = %B@]"
      "class_id" cls.Class.index
      "method_id" meth.Method.index
      "synchronous" meth.Method.synchronous

  (* method responses *)

  let rec find_method_for_name name = function
    | [] -> failwith ("No method found for name: " ^ name)
    | meth :: methods ->
      if meth.Method.name = name
      then meth
      else find_method_for_name name methods

  let fmt_method_response cls ppf response =
    let meth = find_method_for_name response.Response.name cls.Class.methods in
    Format.fprintf ppf "(%d, %d);" cls.Class.index meth.Method.index

  let fmt_method_responses ppf (cls, meth) =
    fmt_list_in_vbox ppf "let responses = [" "]"
      (fmt_method_response cls) meth.Method.responses

  (* type record *)

  let fmt_method_record_field spec ppf field =
    let ocaml_type, domain, _ = types_from_field spec field in
    Format.fprintf ppf "%s : %s (* %s *);"
      (make_field_name field) ocaml_type domain

  let fmt_method_record ppf (spec, cls, meth) =
    match meth.Method.fields with
    | [] -> Format.fprintf ppf "type record = ()"
    | fields -> fmt_list_in_vbox ppf "type record = {" "}"
                  (fmt_method_record_field spec) fields

  (* arguments list *)

  let fmt_argument_field spec fmt_arg ppf field =
    let _, _, amqp_type = types_from_field spec field in
    Format.fprintf ppf "%S, %s;" field.Field.name
      (fmt_arg amqp_type (make_field_name field))

  let fmt_argument_list ppf (spec, cls, meth) =
    let fmt_arg amqp_type name = Printf.sprintf "Field_type.%s" amqp_type in
    fmt_list_in_vbox ppf "let arguments = [" "]"
      (fmt_argument_field spec fmt_arg) meth.Method.fields

  (* t_to_list *)

  let fmt_t_to_list ppf (spec, cls, meth) =
    let fmt_arg amqp_type name =
      Printf.sprintf "Amqp_field.%s payload.%s" amqp_type name
    in
    fmt_function ppf "let t_to_list payload =@," (fun ppf ->
        fmt_list_in_vbox ppf "[" "]"
          (fmt_argument_field spec fmt_arg) meth.Method.fields
      )

  (* t_from_list *)

  let fmt_t_from_list ppf (spec, cls, meth) =
    let fmt_arg amqp_type name =
      Printf.sprintf "Amqp_field.%s %s" amqp_type name
    in
    fmt_function ppf "let t_from_list fields =" (fun ppf ->
        Format.fprintf ppf "@,match fields with@,";
        fmt_list_in_vbox ppf "| [" "] "
          (fmt_argument_field spec fmt_arg) meth.Method.fields;
        (match meth.Method.fields with
         | [] -> Format.fprintf ppf "-> ()"
         | fields ->
           fmt_list_in_vbox ppf "-> {" "}"
             (fun ppf field -> Format.fprintf ppf "%s;" (make_field_name field))
             fields);
        Format.pp_print_cut ppf ();
        Format.fprintf ppf "| _ -> failwith \"Unexpected fields.\""
      )

  (* make_t *)

  let make_arg field =
    if field.Field.reserved
    then ""
    else "~" ^ make_field_name field ^ " "

  let fmt_record_entry spec ppf field =
    let name = make_field_name field in
    if field.Field.reserved
    then
      let ocaml_type, _, _ = types_from_field spec field in
      let value = reserved_value_for_ocaml_type ocaml_type in
      Format.fprintf ppf "%s = %s;" name value
    else Format.fprintf ppf "%s;" name

  let fmt_make_t ppf (spec, cls, meth) =
    let params = match meth.Method.fields with
      | [] -> ""
      | fields -> String.concat "" (List.map make_arg fields)
    in
    fmt_function ppf ("let make_t " ^ params ^ "() =") (fun ppf ->
        Format.pp_print_cut ppf ();
        let constructor = "`" ^ String.capitalize (make_method_name cls meth) in
        match meth.Method.fields with
          | [] -> Format.fprintf ppf "%s ()" constructor
          | fields -> fmt_list_in_vbox ppf (constructor ^ " {") "}"
                        (fmt_record_entry spec) fields)

  (* method module *)

  let fmt_method_text ppf (spec, cls, meth) =
    let module_name = String.capitalize (make_method_name cls meth) in
    let fmt_line ppf = Format.fprintf ppf "@;<0 -2>@,%a" in
    fmt_module ppf module_name (fun ppf ->
        Format.fprintf ppf "@,open Protocol";
        fmt_line ppf fmt_method_constants (cls, meth);
        fmt_line ppf fmt_method_responses (cls, meth);
        fmt_line ppf fmt_method_record (spec, cls, meth);
        fmt_line ppf fmt_argument_list (spec, cls, meth);
        fmt_line ppf fmt_t_to_list (spec, cls, meth);
        fmt_line ppf fmt_t_from_list (spec, cls, meth);
        fmt_line ppf fmt_make_t (spec, cls, meth);
      );
    Format.fprintf ppf "@."

  let make_method_text spec cls meth =
    Format.fprintf Format.str_formatter "%a" fmt_method_text (spec, cls, meth);
    Format.flush_str_formatter ()

  let build (spec, cls, meth) =
    let module_name = make_method_name cls meth in
    {
      name = module_name;
      text = make_method_text spec cls meth;
    }
end


module Method_module_wrapper = struct

  let fmt_method_text ppf (spec, cls, meth) =
    let method_name = make_method_name cls meth in
    let module_name = String.capitalize method_name in
    let fmt_line ppf = Format.fprintf ppf "@;<0 -2>@,%a" in
    let fmt_line_str ppf = fmt_line ppf Format.pp_print_string in
    let fmt_function ppf = fmt_line_str ppf ""; fmt_function ppf in
    fmt_module ppf module_name (fun ppf ->
        Format.fprintf ppf "@,%s@,%s@,include Gen_%s.%s"
          "open Generated_method_types" "open Protocol.Method_utils"
          method_name module_name;
        fmt_line ppf (fun ppf -> Format.fprintf ppf "type t = [`%s of record]") module_name;
        fmt_line_str ppf "let buf_to_list = buf_to_list arguments";
        fmt_line_str ppf "let string_of_list = string_of_list class_id method_id";
        fmt_line_str ppf "let dump_list = dump_list class_id method_id";
        fmt_function ppf "let parse_method buf =" (fun ppf ->
            Format.fprintf ppf
              "@,(`%s (t_from_list (buf_to_list buf)) :> method_payload)"
              module_name);
        fmt_function ppf "let build_method = function" (fun ppf ->
            Format.fprintf ppf
              "@,| `%s payload -> string_of_list (t_to_list payload)@,| _ -> assert false"
              module_name);
        fmt_function ppf "let dump_method = function" (fun ppf ->
            Format.fprintf ppf
              "@,| `%s payload -> dump_list (t_to_list payload)@,| _ -> assert false"
              module_name);
        fmt_function ppf "let list_of_t = function" (fun ppf ->
            Format.fprintf ppf
              "@,| `%s payload -> t_to_list payload@,| _ -> assert false"
              module_name);
      )

  let build (spec, cls, meth) =
    Format.fprintf Format.str_formatter "%a" fmt_method_text (spec, cls, meth);
    Format.flush_str_formatter ()
end


module Method_builder_list = struct

  let fmt_builder ppf (spec, cls, meth) =
    Format.fprintf ppf "@,| (%d, %d) -> %s.parse_method"
      cls.Class.index meth.Method.index (String.capitalize (make_method_name cls meth))

  let fmt_builder_list ppf spec =
    fmt_function ppf "let build_method_instance = function" (fun ppf ->
        iter_methods spec (fmt_builder ppf);
        Format.fprintf ppf "@,| (class_id, method_id) ->@,%s"
          "  failwith (Printf.sprintf \"Unknown method: (%d, %d)\" class_id method_id)")

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_builder_list spec;
    Format.flush_str_formatter ()
end


module Module_for_method_list = struct

  let fmt_builder ppf (spec, cls, meth) =
    Format.fprintf ppf "@,| `%s _ -> (module %s : Method)"
      (String.capitalize (make_method_name cls meth))
      (String.capitalize (make_method_name cls meth))

  let fmt_builder_list ppf spec =
    fmt_function ppf "let module_for = function" (fun ppf ->
        iter_methods spec (fmt_builder ppf);
        Format.fprintf ppf "@.")

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_builder_list spec;
    Format.flush_str_formatter ()
end


module Method_type_list = struct

  let fmt_type ppf (spec, cls, meth) =
    let method_name = make_method_name cls meth in
    let module_name = String.capitalize method_name in
    Format.fprintf ppf "| `%s of Gen_%s.%s.record"
      module_name method_name module_name

  let fmt_type_list ppf spec =
    fmt_list_in_vbox ppf "type method_payload = [" "]"
      fmt_type (map_methods spec (fun x -> x))

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_type_list spec;
    Format.flush_str_formatter ()
end


module Method_module_type = struct

  let fmt_method_type ppf () =
    let fmt_line ppf = Format.fprintf ppf "@;<0 -2>@,%a" in
    let fmt_line_str ppf = fmt_line ppf Format.pp_print_string in
    fmt_module_type ppf "Method" (fun ppf ->
        Format.fprintf ppf "@,type t@,open Generated_method_types";
        fmt_line_str ppf "val class_id : int";
        fmt_line_str ppf "val method_id : int";
        fmt_line_str ppf "val synchronous : bool";
        fmt_line_str ppf "val responses : (int * int) list";
        fmt_line_str ppf (
          "val parse_method : Parse_utils.Parse_buf.t -> method_payload");
        fmt_line_str ppf
          "val build_method : method_payload -> string";
        fmt_line_str ppf
          "val dump_method : method_payload -> string")

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_method_type ();
    Format.flush_str_formatter ()
end


module Frame_constants = struct

  let fmt_frame_end ppf spec =
    Format.fprintf ppf "let frame_end = %d" (get_constant_value "frame-end" spec.Spec.constants)

  let fmt_frame_type ppf () =
    (* Not a function, but it looks like one. *)
    fmt_function ppf "type frame_type =" (fun ppf ->
        Format.fprintf ppf "@,| Method_frame";
        Format.fprintf ppf "@,| Header_frame";
        Format.fprintf ppf "@,| Body_frame";
        Format.fprintf ppf "@,| Heartbeat_frame")

  let fmt_byte_to_frame_type ppf spec =
    let get_constant name = get_constant_value name spec.Spec.constants in
    fmt_function ppf "let byte_to_frame_type = function" (fun ppf ->
        Format.fprintf ppf "@,| %d -> Method_frame" (get_constant "frame-method");
        Format.fprintf ppf "@,| %d -> Header_frame" (get_constant "frame-header");
        Format.fprintf ppf "@,| %d -> Body_frame" (get_constant "frame-body");
        Format.fprintf ppf "@,| %d -> Heartbeat_frame" (get_constant "frame-heartbeat");
        Format.fprintf ppf "@,| i -> failwith (Printf.sprintf %S i)" "Unexpected frame type: %d")

  let fmt_emit_frame_type ppf spec =
    let get_constant name = get_constant_value name spec.Spec.constants in
    fmt_function ppf "let emit_frame_type = function" (fun ppf ->
        Format.fprintf ppf "@,| Method_frame -> String.make 1 (char_of_int %d)"
          (get_constant "frame-method");
        Format.fprintf ppf "@,| Header_frame -> String.make 1 (char_of_int %d)"
          (get_constant "frame-header");
        Format.fprintf ppf "@,| Body_frame -> String.make 1 (char_of_int %d)"
          (get_constant "frame-body");
        Format.fprintf ppf "@,| Heartbeat_frame -> String.make 1 (char_of_int %d)"
          (get_constant "frame-heartbeat"))

  let fmt_frame_constants ppf spec =
    Format.fprintf ppf "@[<v>";
    Format.fprintf ppf "%a@,@," fmt_frame_end spec;
    Format.fprintf ppf "%a@,@," fmt_frame_type ();
    Format.fprintf ppf "%a@,@," fmt_byte_to_frame_type spec;
    Format.fprintf ppf "%a@," fmt_emit_frame_type spec;
    Format.fprintf ppf "@]"

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_frame_constants spec;
    Format.flush_str_formatter ()
end


let build_methods spec =
  map_methods spec Method_module.build

let build_method_wrappers spec =
  map_methods spec Method_module_wrapper.build

let build_method_builders spec =
  Method_builder_list.build spec

let build_module_for_method spec =
  Module_for_method_list.build spec

let build_method_types spec =
  Method_type_list.build spec

let build_method_module_type spec =
  Method_module_type.build spec

let build_frame_constants spec =
  Frame_constants.build spec
