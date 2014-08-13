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


let name_to_ocaml name =
  match String.map (function '-' -> '_' | c -> c) name with
  | "type" -> "type_"
  | "open" -> "open_"
  | name -> name


let map_methods spec f =
  let map_cls_methods cls =
    List.map (fun meth -> f (spec, cls, meth)) cls.Class.methods
  in
  let map_and_collect acc cls =
    List.rev_append (map_cls_methods cls) acc
  in
  List.rev (List.fold_left map_and_collect [] spec.Spec.classes)


let iter_methods spec f =
  let iter_cls_methods cls =
    List.iter (fun meth -> f (spec, cls, meth)) cls.Class.methods
  in
  List.iter iter_cls_methods spec.Spec.classes


let map_content_classes spec f =
  let is_content_class cls = cls.Class.fields <> [] in
  List.map (fun cls -> f (spec, cls))
    (List.filter is_content_class spec.Spec.classes)


let iter_content_classes spec f =
  ignore (map_content_classes spec f)


let make_method_name cls meth =
  name_to_ocaml (Printf.sprintf "%s_%s" cls.Class.name meth.Method.name)


let make_field_name field =
  name_to_ocaml field.Field.name


let rec get_constant_value name = function
  | [] -> failwith ("Undefined constant: " ^ name)
  | const :: _ when const.Constant.name = name -> const.Constant.value
  | _ :: constants -> get_constant_value name constants


let ocaml_type_from_amqp_type = function
  | "bit" -> "bool"
  | "long" -> "int32"
  | "longlong" -> "int64"
  | "longstr" -> "string"
  | "octet" -> "int"
  | "short" -> "int"
  | "shortstr" -> "string"
  | "table" -> "Ypotryll_field_types.Table.t"
  | "timestamp" -> "int64"
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
  | "int32" -> Printf.sprintf "%dl" 0
  | "int64" -> Printf.sprintf "%dL" 0
  | "string" -> Printf.sprintf "%S" ""
  | "Ypotryll_field_types.Table.t" -> "[]"
  | ocaml_type -> failwith ("Unexpected OCaml type: " ^ ocaml_type)


let types_from_domain spec domain_name =
  let rec inner = function
    | [] -> failwith ("Domain not found: " ^ domain_name)
    | dom :: domains when dom.Domain.name <> domain_name -> inner domains
    | dom :: _ ->
      (ocaml_type_from_amqp_type dom.Domain.data_type, dom.Domain.data_type)
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
