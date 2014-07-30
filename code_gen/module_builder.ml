open Amqp_spec


type method_module = {
  name : string;
  text : string;
}




let make_module_name cls meth =
  String.map (function
      | '-' -> '_'
      | c -> c
    ) @@ Printf.sprintf "%s_%s" cls.Class.name meth.Method.name

let fmt_index_vals ppf (cls, meth) =
  Format.fprintf ppf "@[<v>val class_id = %d@;val method_id = %d@;@]"
    cls.Class.index meth.Method.index

let field_type_from_type = function
  | "bit" -> "bool"
  | "long" -> "int"
  | "longlong" -> "int"
  | "longstr" -> "string"
  | "octet" -> "int"
  | "short" -> "int"
  | "shortstr" -> "string"
  | "table" -> "Table.t"
  | "timestamp" -> "int"
  | data_type -> failwith ("Unexpected type: " ^ data_type)

let field_types_from_domain spec domain_name =
  let rec inner = function
    | [] -> failwith ("Domain not found: " ^ domain_name)
    | domain :: domains ->
      if domain.Domain.name <> domain_name
      then inner domains
      else ((field_type_from_type domain.Domain.data_type),
            (domain_name ^ " : " ^ domain.Domain.data_type))
  in
  inner spec.Spec.domains

let fmt_method_t_field spec ppf field =
  let ocaml_type, amqp_type = match (field.Field.domain, field.Field.data_type) with
    | (Some domain_name, None) -> field_types_from_domain spec domain_name
    | (None, Some data_type) -> (field_type_from_type data_type), data_type
    | _ -> assert false
  in
  Format.fprintf ppf "@;%s : %s (* %s *);" field.Field.name ocaml_type amqp_type

let fmt_method_t ppf (spec, cls, meth) =
  Format.fprintf ppf "@[<v 2>type t = {";
  List.iter (fmt_method_t_field spec ppf) meth.Method.fields;
  Format.fprintf ppf "@;<0 -2>}@]"

let fmt_method_body ppf (spec, cls, meth) =
  Format.fprintf ppf "@[<v 2>module %s = struct@;%a@;%a@;<0 -2>end@]"
    (String.capitalize @@ make_module_name cls meth)
    fmt_index_vals (cls, meth)
    fmt_method_t (spec, cls, meth)

let make_method_text spec cls meth =
  Format.asprintf "@[<v>%s@;@;open Protocol@;@;%a@]"
    "(* This is generated code. *)"
    fmt_method_body (spec, cls, meth)

let build_method spec cls meth =
  let module_name = make_module_name cls meth in
  {
    name = module_name;
    text = make_method_text spec cls meth;
  }


let build_methods spec =
  List.iter (fun cls ->
      Printf.printf "Class %S %d\n" cls.Class.name cls.Class.index;
      List.iter (fun meth ->
          Printf.printf "  Method %S %d\n" meth.Method.name meth.Method.index;
        ) cls.Class.methods
    ) spec.Spec.classes;
  let cls = List.hd spec.Spec.classes in
  let meth = List.hd cls.Class.methods in
  print_endline @@ (build_method spec cls meth).text
