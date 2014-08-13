open Amqp_spec

open Builder_tools


module Method_module = struct

  (* stuff for building method modules *)

  type t = {
    name : string;
    text : string;
  }

  let fmt_method_constants ppf (cls, meth) =
    Format.fprintf ppf
      "@[<v>let %s = %S@;let %s = %d@;let %s = %d@;let %s = %B@]"
      "name" (cls.Class.name ^ "." ^ meth.Method.name)
      "class_id" cls.Class.index
      "method_id" meth.Method.index
      "synchronous" meth.Method.synchronous

  (* method responses *)

  let rec find_method_for_name name = function
    | [] -> failwith ("No method found for name: " ^ name)
    | meth :: _ when meth.Method.name = name -> meth
    | _ :: methods -> find_method_for_name name methods

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
    | [] -> Format.fprintf ppf "type record = unit"
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
          (fmt_argument_field spec fmt_arg) meth.Method.fields)

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
        Format.fprintf ppf "| _ -> failwith \"Unexpected fields.\"")

  (* make_t *)

  let make_arg field =
    match field.Field.reserved with
    | true -> ""
    | false -> "~" ^ make_field_name field ^ " "

  let fmt_record_entry spec ppf field =
    let name = make_field_name field in
    match field.Field.reserved with
    | false -> Format.fprintf ppf "%s;" name
    | true ->
      let ocaml_type, _, _ = types_from_field spec field in
      let value = reserved_value_for_ocaml_type ocaml_type in
      Format.fprintf ppf "%s = %s;" name value

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
        fmt_line ppf fmt_make_t (spec, cls, meth));
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


module Content_module = struct

  (* stuff for building content modules *)

  type t = {
    name : string;
    text : string;
  }

  let fmt_content_constants ppf cls =
    Format.fprintf ppf
      "@[<v>let %s = %S@;let %s = %d@]"
      "name" cls.Class.name
      "class_id" cls.Class.index

  (* type record *)

  let fmt_content_record_field spec ppf field =
    let ocaml_type, domain, _ = types_from_field spec field in
    Format.fprintf ppf "%s : %s option (* %s *);"
      (make_field_name field) ocaml_type domain

  let fmt_content_record ppf (spec, cls) =
    match cls.Class.fields with
    | [] -> Format.fprintf ppf "type record = unit"
    | fields -> fmt_list_in_vbox ppf "type record = {" "}"
                  (fmt_content_record_field spec) fields

  (* property list *)

  let fmt_property_field spec fmt_arg ppf field =
    let _, _, amqp_type = types_from_field spec field in
    Format.fprintf ppf "%S, %s;" field.Field.name
      (fmt_arg amqp_type (make_field_name field))

  let fmt_property_list ppf (spec, cls) =
    let fmt_arg amqp_type name = Printf.sprintf "Field_type.%s" amqp_type in
    fmt_list_in_vbox ppf "let properties = [" "]"
      (fmt_property_field spec fmt_arg) cls.Class.fields

  (* t_to_list *)

  let fmt_t_to_list ppf (spec, cls) =
    let fmt_arg amqp_type name =
      Printf.sprintf "maybe (fun x -> Amqp_field.%s x) payload.%s"
        amqp_type name
    in
    fmt_function ppf "let t_to_list payload =@," (fun ppf ->
        fmt_list_in_vbox ppf "[" "]"
          (fmt_property_field spec fmt_arg) cls.Class.fields)

  (* t_from_list *)

  let fmt_t_from_list ppf (spec, cls) =
    let fmt_arg amqp_type name =
      Printf.sprintf "((None | Some (Amqp_field.%s _)) as %s)" amqp_type name
    in
    let fmt_field ppf field =
      let _, _, amqp_type = types_from_field spec field in
      let name = make_field_name field in
      Format.fprintf ppf
        "%s = maybe (function Amqp_field.%s x -> x | _ -> assert false) %s;"
        name amqp_type name
    in
    fmt_function ppf "let t_from_list fields =" (fun ppf ->
        Format.fprintf ppf "@,match fields with@,";
        fmt_list_in_vbox ppf "| [" "] "
          (fmt_property_field spec fmt_arg) cls.Class.fields;
        (match cls.Class.fields with
         | [] -> Format.fprintf ppf "-> ()"
         | fields ->
           fmt_list_in_vbox ppf "-> {" "}"
             fmt_field fields);
        Format.pp_print_cut ppf ();
        Format.fprintf ppf "| _ -> failwith \"Unexpected fields.\"")

  (* make_t *)

  let make_prop field =
    "?" ^ make_field_name field ^ " "

  let fmt_record_entry spec ppf field =
    let name = make_field_name field in
    match field.Field.reserved with
    | false -> Format.fprintf ppf "%s;" name
    | true ->
      let ocaml_type, _, _ = types_from_field spec field in
      let value = reserved_value_for_ocaml_type ocaml_type in
      Format.fprintf ppf "%s = %s;" name value

  let fmt_make_t ppf (spec, cls) =
    let params = String.concat "" (List.map make_prop cls.Class.fields) in
    fmt_function ppf ("let make_t " ^ params ^ "() =") (fun ppf ->
        Format.pp_print_cut ppf ();
        let constructor =
          "`" ^ String.capitalize (name_to_ocaml cls.Class.name)
        in
        fmt_list_in_vbox ppf (constructor ^ " {") "}"
          (fmt_record_entry spec) cls.Class.fields)

  (* content module *)

  let fmt_module_text ppf (spec, cls) =
    let module_name = String.capitalize (name_to_ocaml cls.Class.name) in
    let fmt_line ppf = Format.fprintf ppf "@;<0 -2>@,%a" in
    fmt_module ppf module_name (fun ppf ->
        Format.fprintf ppf "@,open Protocol";
        fmt_line ppf fmt_content_constants cls;
        fmt_line ppf fmt_content_record (spec, cls);
        fmt_line ppf fmt_property_list (spec, cls);
        fmt_line ppf fmt_t_to_list (spec, cls);
        fmt_line ppf fmt_t_from_list (spec, cls);
        fmt_line ppf fmt_make_t (spec, cls));
    Format.fprintf ppf "@."

  let make_module_text spec cls =
    Format.fprintf Format.str_formatter "%a" fmt_module_text (spec, cls);
    Format.flush_str_formatter ()

  let build (spec, cls) =
    let module_name = name_to_ocaml cls.Class.name in
    {
      name = module_name;
      text = make_module_text spec cls;
    }
end


module Method_module_wrapper = struct

  let fmt_parse_method ppf module_name =
    fmt_function ppf "let parse_method buf =" (fun ppf ->
        Format.fprintf ppf "@,`%s (t_from_list (buf_to_list buf))" module_name)

  let fmt_build_method ppf module_name =
    fmt_function ppf "let build_method = function" (fun ppf ->
        Format.fprintf ppf
          "@,| `%s payload -> string_of_list (t_to_list payload)" module_name;
        Format.fprintf ppf "@,| _ -> assert false")

  let fmt_dump_method ppf module_name =
    fmt_function ppf "let dump_method = function" (fun ppf ->
        Format.fprintf ppf
          "@,| `%s payload -> dump_list (t_to_list payload)" module_name;
        Format.fprintf ppf "@,| _ -> assert false")

  let fmt_list_of_t ppf module_name =
    fmt_function ppf "let list_of_t = function" (fun ppf ->
        Format.fprintf ppf "@,| `%s payload -> t_to_list payload" module_name;
        Format.fprintf ppf "@,| _ -> assert false")

  let fmt_method_text ppf (spec, cls, meth) =
    let method_name = make_method_name cls meth in
    let module_name = String.capitalize method_name in
    let fmt_line ppf = Format.fprintf ppf "@;<0 -2>@,%a" in
    let fmt_line_str ppf = fmt_line ppf Format.pp_print_string in
    fmt_module ppf module_name (fun ppf ->
        Format.fprintf ppf "@,%s@,include Gen_%s.%s"
          "open Protocol.Method_utils"
          method_name module_name;
        fmt_line ppf (fun ppf ->
            Format.fprintf ppf "type t = [`%s of record]") module_name;
        fmt_line_str ppf "let buf_to_list = buf_to_list arguments";
        fmt_line_str ppf
          "let string_of_list = string_of_list class_id method_id";
        fmt_line_str ppf "let dump_list = dump_list name class_id method_id";
        fmt_line ppf fmt_parse_method module_name;
        fmt_line ppf fmt_build_method module_name;
        fmt_line ppf fmt_dump_method module_name;
        fmt_line ppf fmt_list_of_t module_name)

  let build (spec, cls, meth) =
    Format.fprintf Format.str_formatter "%a" fmt_method_text (spec, cls, meth);
    Format.flush_str_formatter ()
end


module Content_module_wrapper = struct

  let fmt_parse_header ppf module_name =
    fmt_function ppf "let parse_header buf =" (fun ppf ->
        Format.fprintf ppf "@,`%s (t_from_list (buf_to_list buf))" module_name)

  let fmt_build_header ppf module_name =
    fmt_function ppf "let build_header = function" (fun ppf ->
        Format.fprintf ppf
          "@,| size, `%s payload -> string_of_list size (t_to_list payload)"
          module_name;
        Format.fprintf ppf "@,| _ -> assert false")

  let fmt_dump_header ppf module_name =
    fmt_function ppf "let dump_header = function" (fun ppf ->
        Format.fprintf ppf
          "@,| size, `%s payload -> dump_list size (t_to_list payload)"
          module_name;
        Format.fprintf ppf "@,| _ -> assert false")

  let fmt_list_of_t ppf module_name =
    fmt_function ppf "let list_of_t = function" (fun ppf ->
        Format.fprintf ppf "@,| `%s payload -> t_to_list payload" module_name;
        Format.fprintf ppf "@,| _ -> assert false")

  let fmt_module_text ppf (spec, cls) =
    let class_name = name_to_ocaml cls.Class.name in
    let module_name = String.capitalize class_name in
    let fmt_line ppf = Format.fprintf ppf "@;<0 -2>@,%a" in
    let fmt_line_str ppf = fmt_line ppf Format.pp_print_string in
    fmt_module ppf module_name (fun ppf ->
        Format.fprintf ppf "@,%s@,include Gen_%s.%s"
          "open Protocol.Header_utils"
          class_name module_name;
        fmt_line ppf (fun ppf ->
            Format.fprintf ppf "type t = [`%s of record]") module_name;
        fmt_line_str ppf "let buf_to_list = buf_to_list properties";
        fmt_line_str ppf
          "let string_of_list = string_of_list class_id";
        fmt_line_str ppf "let dump_list = dump_list name class_id";
        fmt_line ppf fmt_parse_header module_name;
        fmt_line ppf fmt_build_header module_name;
        fmt_line ppf fmt_dump_header module_name;
        fmt_line ppf fmt_list_of_t module_name)

  let build (spec, cls) =
    Format.fprintf Format.str_formatter "%a" fmt_module_text (spec, cls);
    Format.flush_str_formatter ()
end


module Method_parser_list = struct

  let fmt_builder ppf (spec, cls, meth) =
    Format.fprintf ppf "@,| (%d, %d) -> %s.parse_method"
      cls.Class.index meth.Method.index
      (String.capitalize (make_method_name cls meth))

  let fmt_builder_list ppf spec =
    fmt_function ppf "let parse_method = function" (fun ppf ->
        iter_methods spec (fmt_builder ppf);
        Format.fprintf ppf "@,| (class_id, method_id) ->@,  %s"
          (Printf.sprintf "failwith (Printf.sprintf %S class_id method_id)"
             "Unknown method: (%d, %d)"))

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_builder_list spec;
    Format.flush_str_formatter ()
end


module Header_parser_list = struct

  let fmt_builder ppf (spec, cls) =
    Format.fprintf ppf "@,| %d -> %s.parse_header"
      cls.Class.index (String.capitalize (name_to_ocaml cls.Class.name))

  let fmt_builder_list ppf spec =
    fmt_function ppf "let parse_header = function" (fun ppf ->
        iter_content_classes spec (fmt_builder ppf);
        Format.fprintf ppf "@,| class_id ->@,  %s"
          (Printf.sprintf "failwith (Printf.sprintf %S class_id)"
             "Unknown content class: %d"))

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_builder_list spec;
    Format.flush_str_formatter ()
end


module Module_for_method_list = struct

  let fmt_builder ppf (spec, cls, meth) =
    let module_name = String.capitalize (make_method_name cls meth) in
    Format.fprintf ppf "@,| `%s _ -> (module %s : Method)"
      module_name module_name

  let fmt_builder_list ppf spec =
    fmt_function ppf "let module_for = function" (fun ppf ->
        iter_methods spec (fmt_builder ppf);
        Format.fprintf ppf "@.")

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_builder_list spec;
    Format.flush_str_formatter ()
end


module Module_for_content_list = struct

  let fmt_builder ppf (spec, cls) =
    let module_name = String.capitalize (name_to_ocaml cls.Class.name) in
    Format.fprintf ppf "@,| `%s _ -> (module %s : Header)"
      module_name module_name

  let fmt_builder_list ppf spec =
    fmt_function ppf "let module_for = function" (fun ppf ->
        iter_content_classes spec (fmt_builder ppf);
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


module Content_type_list = struct

  let fmt_type ppf (spec, cls) =
    let class_name = name_to_ocaml cls.Class.name in
    let module_name = String.capitalize class_name in
    Format.fprintf ppf "| `%s of Gen_%s.%s.record"
      module_name class_name module_name

  let fmt_type_list ppf spec =
    fmt_list_in_vbox ppf "type header_payload = [" "]"
      fmt_type (map_content_classes spec (fun x -> x))

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
        fmt_line_str ppf "val name : string";
        fmt_line_str ppf "val class_id : int";
        fmt_line_str ppf "val method_id : int";
        fmt_line_str ppf "val synchronous : bool";
        fmt_line_str ppf "val responses : (int * int) list";
        fmt_line_str ppf (
          "val parse_method : Parse_utils.Parse_buf.t ->"
          ^ " Ypotryll_types.method_payload");
        fmt_line_str ppf
          "val build_method : Ypotryll_types.method_payload -> string";
        fmt_line_str ppf
          "val dump_method : Ypotryll_types.method_payload -> string")

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_method_type ();
    Format.flush_str_formatter ()
end


module Content_module_type = struct

  let fmt_content_type ppf () =
    let fmt_line ppf = Format.fprintf ppf "@;<0 -2>@,%a" in
    let fmt_line_str ppf = fmt_line ppf Format.pp_print_string in
    fmt_module_type ppf "Header" (fun ppf ->
        Format.fprintf ppf "@,type t";
        fmt_line_str ppf "val name : string";
        fmt_line_str ppf "val class_id : int";
        fmt_line_str ppf (
          "val parse_header : Parse_utils.Parse_buf.t ->"
          ^ " Ypotryll_types.header_payload");
        fmt_line_str ppf
          "val build_header : int64 * Ypotryll_types.header_payload -> string";
        fmt_line_str ppf
          "val dump_header : int64 * Ypotryll_types.header_payload -> string")

  let build spec =
    Format.fprintf Format.str_formatter "%a" fmt_content_type ();
    Format.flush_str_formatter ()
end


module Frame_constants = struct

  let fmt_frame_end ppf spec =
    Format.fprintf ppf "let frame_end = %d"
      (get_constant_value "frame-end" spec.Spec.constants)

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
        Format.fprintf ppf "@,| %d -> Method_frame"
          (get_constant "frame-method");
        Format.fprintf ppf "@,| %d -> Header_frame"
          (get_constant "frame-header");
        Format.fprintf ppf "@,| %d -> Body_frame"
          (get_constant "frame-body");
        Format.fprintf ppf "@,| %d -> Heartbeat_frame"
          (get_constant "frame-heartbeat");
        Format.fprintf ppf "@,| i -> failwith (Printf.sprintf %S i)"
          "Unexpected frame type: %d")

  let fmt_emit_frame_type ppf spec =
    let get_constant name = get_constant_value name spec.Spec.constants in
    fmt_function ppf "let emit_frame_type = function" (fun ppf ->
        Format.fprintf ppf "@,| Method_frame -> String.make 1 (char_of_int %d)"
          (get_constant "frame-method");
        Format.fprintf ppf "@,| Header_frame -> String.make 1 (char_of_int %d)"
          (get_constant "frame-header");
        Format.fprintf ppf "@,| Body_frame -> String.make 1 (char_of_int %d)"
          (get_constant "frame-body");
        Format.fprintf ppf
          "@,| Heartbeat_frame -> String.make 1 (char_of_int %d)"
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

let build_contents spec =
  map_content_classes spec Content_module.build

let build_method_wrappers spec =
  map_methods spec Method_module_wrapper.build

let build_content_wrappers spec =
  map_content_classes spec Content_module_wrapper.build

let build_method_parsers spec =
  Method_parser_list.build spec

let build_header_parsers spec =
  Header_parser_list.build spec

let build_module_for_method spec =
  Module_for_method_list.build spec

let build_module_for_content spec =
  Module_for_content_list.build spec

let build_method_types spec =
  Method_type_list.build spec

let build_content_types spec =
  Content_type_list.build spec

let build_method_module_type spec =
  Method_module_type.build spec

let build_content_module_type spec =
  Content_module_type.build spec

let build_frame_constants spec =
  Frame_constants.build spec
