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


module Method_module = struct

  (* stuff for building method modules *)

  type t = {
    name : string;
    text : string;
  }

  let fmt_index_vals ppf (cls, meth) =
    Format.fprintf ppf "@[<v>let class_id = %d@;let method_id = %d@]"
      cls.Class.index meth.Method.index

  (* type record *)

  let ocaml_field_type_from_type = function
    | "bit" -> "bool"
    | "long" -> "int"
    | "longlong" -> "int"
    | "longstr" -> "string"
    | "octet" -> "int"
    | "short" -> "int"
    | "shortstr" -> "string"
    | "table" -> "Amqp_table.table"
    | "timestamp" -> "int"
    | data_type -> failwith ("Unexpected type: " ^ data_type)

  let ocaml_field_types_from_domain spec domain_name =
    let rec inner = function
      | [] -> failwith ("Domain not found: " ^ domain_name)
      | domain :: domains ->
        if domain.Domain.name <> domain_name
        then inner domains
        else ((ocaml_field_type_from_type domain.Domain.data_type),
              (domain_name ^ " : " ^ domain.Domain.data_type))
    in
    inner spec.Spec.domains

  let fmt_method_record_field spec ppf field =
    let ocaml_type, amqp_type = match (field.Field.domain, field.Field.data_type) with
      | (Some domain_name, None) -> ocaml_field_types_from_domain spec domain_name
      | (None, Some data_type) -> (ocaml_field_type_from_type data_type), data_type
      | _ -> assert false
    in
    Format.fprintf ppf "%s : %s (* %s *);"
      (make_field_name field) ocaml_type amqp_type

  let fmt_method_record ppf (spec, cls, meth) =
    match meth.Method.fields with
    | [] -> Format.fprintf ppf "type record = ()"
    | fields -> fmt_list_in_vbox ppf "type record = {" "}"
                  (fmt_method_record_field spec) fields

  (* arguments list *)

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
    | data_type -> failwith ("Unexpected type: " ^ data_type)

  let amqp_field_types_from_domain spec domain_name =
    let rec inner = function
      | [] -> failwith ("Domain not found: " ^ domain_name)
      | domain :: domains ->
        if domain.Domain.name <> domain_name
        then inner domains
        else (amqp_field_type_from_type domain.Domain.data_type)
    in
    inner spec.Spec.domains

  let fmt_argument_field spec fmt_arg ppf field =
    let amqp_type = match (field.Field.domain, field.Field.data_type) with
      | (Some domain_name, None) -> amqp_field_types_from_domain spec domain_name
      | (None, Some data_type) -> (amqp_field_type_from_type data_type)
      | _ -> assert false
    in
    Format.fprintf ppf "%S, %s;" field.Field.name
      (fmt_arg amqp_type (make_field_name field))

  let fmt_argument_list ppf (spec, cls, meth) =
    let fmt_arg amqp_type name = Printf.sprintf "Field_type.%s" amqp_type in
    fmt_list_in_vbox ppf "let arguments = [" "]"
      (fmt_argument_field spec fmt_arg) meth.Method.fields

  (* t_to_list *)

  let fmt_t_to_list ppf (spec, cls, meth) =
    let fmt_arg amqp_type name = Printf.sprintf "Amqp_field.%s payload.%s" amqp_type name in
    fmt_function ppf "let t_to_list payload =@," (fun ppf ->
        fmt_list_in_vbox ppf "[" "]"
          (fmt_argument_field spec fmt_arg) meth.Method.fields
      )

  (* t_from_list *)

  let fmt_t_from_list ppf (spec, cls, meth) =
    let fmt_arg amqp_type name = Printf.sprintf "Amqp_field.%s %s" amqp_type name in
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

  (* method module *)

  let fmt_method_text ppf (spec, cls, meth) =
    let module_name = String.capitalize (make_method_name cls meth) in
    let fmt_line ppf = Format.fprintf ppf "@;<0 -2>@,%a" in
    fmt_module ppf module_name (fun ppf ->
        Format.fprintf ppf "@,open Protocol";
        fmt_line ppf fmt_index_vals (cls, meth);
        fmt_line ppf fmt_method_record (spec, cls, meth);
        fmt_line ppf fmt_argument_list (spec, cls, meth);
        fmt_line ppf fmt_t_to_list (spec, cls, meth);
        fmt_line ppf fmt_t_from_list (spec, cls, meth);
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
        fmt_function ppf "let parse_method buf =" (fun ppf ->
            Format.fprintf ppf
              "@,(`%s (t_from_list (buf_to_list buf)) :> method_payload)"
              module_name);
        fmt_function ppf "let build_method = function" (fun ppf ->
            Format.fprintf ppf
              "@,| `%s payload -> string_of_list (t_to_list payload)@,| _ -> assert false"
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
        Format.fprintf ppf "@,| (class_id, method_id) ->@,%s@."
          "  failwith (Printf.sprintf \"Unknown method: (%d, %d)\" class_id method_id)")

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_builder_list spec;
    Format.flush_str_formatter ()
end


module Method_rebuilder_list = struct

  let fmt_builder ppf (spec, cls, meth) =
    Format.fprintf ppf "@,| `%s _ -> (module %s : Generated_method_types.Method)"
      (String.capitalize (make_method_name cls meth))
      (String.capitalize (make_method_name cls meth))

  let fmt_builder_list ppf spec =
    fmt_function ppf "let rebuild_method_instance = function" (fun ppf ->
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
        Format.fprintf ppf "@,type t";
        fmt_line_str ppf "val parse_method : Parse_utils.Parse_buf.t -> method_payload";
        fmt_line_str ppf "val build_method : method_payload -> string";
        fmt_line_str ppf "(* temporary? *)";
        fmt_line_str ppf "val buf_to_list : Parse_utils.Parse_buf.t -> (string * Protocol.Amqp_field.t) list";
        fmt_line_str ppf "val string_of_list : (string * Protocol.Amqp_field.t) list -> string";
        fmt_line_str ppf "val list_of_t : method_payload -> (string * Protocol.Amqp_field.t) list")

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
        Format.fprintf ppf "@,| Method";
        Format.fprintf ppf "@,| Header";
        Format.fprintf ppf "@,| Body";
        Format.fprintf ppf "@,| Heartbeat")

  let fmt_byte_to_frame_type ppf spec =
    let get_constant name = get_constant_value name spec.Spec.constants in
    fmt_function ppf "let byte_to_frame_type = function" (fun ppf ->
        Format.fprintf ppf "@,| %d -> Method" (get_constant "frame-method");
        Format.fprintf ppf "@,| %d -> Header" (get_constant "frame-header");
        Format.fprintf ppf "@,| %d -> Body" (get_constant "frame-body");
        Format.fprintf ppf "@,| %d -> Heartbeat" (get_constant "frame-heartbeat");
        Format.fprintf ppf "@,| i -> failwith (Printf.sprintf %S i)" "Unexpected frame type: %d")

  let fmt_emit_frame_type ppf spec =
    let get_constant name = get_constant_value name spec.Spec.constants in
    fmt_function ppf "let emit_frame_type = function" (fun ppf ->
        Format.fprintf ppf "@,| Method -> String.make 1 (char_of_int %d)"
          (get_constant "frame-method");
        Format.fprintf ppf "@,| Header -> String.make 1 (char_of_int %d)"
          (get_constant "frame-header");
        Format.fprintf ppf "@,| Body -> String.make 1 (char_of_int %d)"
          (get_constant "frame-body");
        Format.fprintf ppf "@,| Heartbeat -> String.make 1 (char_of_int %d)"
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

let build_method_rebuilders spec =
  Method_rebuilder_list.build spec

let build_method_types spec =
  Method_type_list.build spec

let build_method_module_type spec =
  Method_module_type.build spec

let build_frame_constants spec =
  Frame_constants.build spec
