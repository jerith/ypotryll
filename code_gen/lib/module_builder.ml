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

let fmt_list_in_vbox ppf offset start finish fmt_item list =
  let fmt_list ppf =
    List.iter (fun item -> Format.pp_print_cut ppf (); fmt_item ppf item) list
  in
  fmt_in_vbox ppf offset start fmt_list (Some finish)

let fmt_function ppf start fmt_func =
  fmt_in_vbox ppf 2 (start ^ "@,") fmt_func None

let fmt_module ppf module_name fmt_func =
  let start = "module " ^ module_name ^ " = struct" in
  fmt_in_vbox ppf 2 start fmt_func (Some "end")

let name_to_ocaml = String.map (function
    | '-' -> '_'
    | c -> c
  )

let make_method_name cls meth =
  name_to_ocaml (Printf.sprintf "%s_%s" cls.Class.name meth.Method.name)


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
      (name_to_ocaml field.Field.name) ocaml_type amqp_type

  let fmt_method_record ppf (spec, cls, meth) =
    fmt_list_in_vbox ppf 2 "type record = {" "}"
      (fmt_method_record_field spec) meth.Method.fields

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
      (fmt_arg amqp_type (name_to_ocaml field.Field.name))

  let fmt_argument_list ppf (spec, cls, meth) =
    let fmt_arg amqp_type name = Printf.sprintf "Field_type.%s" amqp_type in
    fmt_list_in_vbox ppf 2 "let arguments = [" "]"
      (fmt_argument_field spec fmt_arg) meth.Method.fields

  (* t_to_list *)

  let fmt_t_to_list ppf (spec, cls, meth) =
    let fmt_arg amqp_type name = Printf.sprintf "Amqp_field.%s payload.%s" amqp_type name in
    fmt_function ppf "let t_to_list payload =" (fun ppf ->
        fmt_list_in_vbox ppf 2 "[" "]"
          (fmt_argument_field spec fmt_arg) meth.Method.fields
      )

  (* t_from_list *)

  let fmt_t_from_list ppf (spec, cls, meth) =
    let fmt_arg amqp_type name = Printf.sprintf "Amqp_field.%s %s" amqp_type name in
    fmt_function ppf "let t_from_list fields =" (fun ppf ->
        Format.fprintf ppf "match fields with@,";
        fmt_list_in_vbox ppf 2 "| [" "] "
          (fmt_argument_field spec fmt_arg) meth.Method.fields;
        fmt_list_in_vbox ppf 2 "-> {" "}"
          (fun ppf field -> Format.fprintf ppf "%s;" (name_to_ocaml field.Field.name))
          meth.Method.fields;
        Format.pp_print_cut ppf ();
        Format.fprintf ppf "| _ -> failwith \"Unexpected fields.\""
      )

  (* method module *)

  let fmt_method_text ppf (spec, cls, meth) =
    let module_name = String.capitalize (make_method_name cls meth) in
    let fmt_line ppf = Format.fprintf ppf "@;<0 -2>@,%a" in
    Format.fprintf ppf "@[<v>(* This is generated code. *)@,@,@,@]";
    fmt_module ppf module_name (fun ppf ->
        Format.fprintf ppf "@,open Protocol";
        fmt_line ppf fmt_index_vals (cls, meth);
        fmt_line ppf fmt_method_record (spec, cls, meth);
        fmt_line ppf fmt_argument_list (spec, cls, meth);
        fmt_line ppf fmt_t_to_list (spec, cls, meth);
        fmt_line ppf fmt_t_from_list (spec, cls, meth);
      )

  let make_method_text spec cls meth =
    Format.fprintf Format.str_formatter "%a" fmt_method_text (spec, cls, meth);
    Format.flush_str_formatter ()

  let build spec cls meth =
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
        Format.fprintf ppf "@,include Gen_%s.%s" method_name module_name;
        fmt_line ppf (fun ppf -> Format.fprintf ppf "type t = [`%s of record]") module_name;
        fmt_line_str ppf "let buf_to_list = Protocol.Method_utils.buf_to_list arguments";
        fmt_line_str ppf "let string_of_list = Protocol.Method_utils.string_of_list arguments";
        fmt_function ppf "let parse_method buf =" (fun ppf ->
            Format.fprintf ppf
              "(`%s (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)"
              module_name);
        fmt_function ppf "let build_method = function" (fun ppf ->
            Format.fprintf ppf
              "| `%s payload -> string_of_list (t_to_list payload)@,| _ -> assert false"
              module_name);
        fmt_function ppf "let list_of_t = function" (fun ppf ->
            Format.fprintf ppf
              "| `%s payload -> t_to_list payload@,| _ -> assert false"
              module_name);
      )

  let build spec cls meth =
    Format.asprintf "%a" fmt_method_text (spec, cls, meth)
end


let build_methods spec =
  let cls = List.hd spec.Spec.classes in
  let meth = List.hd cls.Class.methods in
  print_endline (Method_module.build spec cls meth).Method_module.text

let build_method_wrappers spec =
  let cls = List.hd spec.Spec.classes in
  let meth = List.hd cls.Class.methods in
  print_endline (Method_module_wrapper.build spec cls meth)
