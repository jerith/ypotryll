open Amqp_spec

type xml_tree =
  | E of string * Xmlm.attribute list * xml_tree list
  | D of string

let in_tree i =
  let el ((_, name), attrs) children = E (name, attrs, children)  in
  let data d = D d in
  Xmlm.input_doc_tree ~el ~data i

let rec get_attr_option name = function
  | [] -> None
  | ((_, attrname), value) :: tl ->
    if attrname = name
    then Some value
    else get_attr_option name tl

let get_attr name attrs =
  match get_attr_option name attrs with
  | None -> failwith ("Attr not found: " ^ name)
  | Some value -> value

let get_bool_attr name attrs =
  match get_attr_option name attrs with
  | None -> false
  | Some "1" -> true
  | Some value -> failwith ("Unexpected boolean attr value: " ^ value)

let get_int_attr name attrs =
  int_of_string @@ get_attr name attrs

let fmt_tag name attrs =
  let fmt_attr ((_, name), value) =
    Printf.sprintf "%s=%S" name value
  in
  let fmt_attrs = function
    | [] -> ""
    | attrs -> " " ^ String.concat " " @@ List.map fmt_attr attrs
  in
  Printf.sprintf "<%s%s>" name (fmt_attrs attrs)

let swallow_element f collected elems = function
  | D _ -> f collected elems
  | E ("doc", _, _) -> f collected elems
  | E (tag, attrs, _) -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag tag attrs))

let rec consume_children children =
  let rec inner () = function
    | [] -> ()
    | elem :: elems -> swallow_element inner () elems elem
  in
  inner () children


let parse_constant attrs children =
  let name = get_attr "name" attrs in
  let value = get_int_attr "value" attrs in
  let cls = get_attr_option "class" attrs in
  let () = consume_children children in
  Constant.make name value cls

let parse_rule attrs children =
  let name = get_attr "name" attrs in
  let () = consume_children children in
  Rule.make name

let parse_assert attrs children =
  let check = get_attr "check" attrs in
  let value = get_attr_option "value" attrs in
  let () = consume_children children in
  Assert.make check value

let parse_domain_children domain elems =
  let open Domain in
  let rec inner domain = function
    | [] -> domain
    | E ("rule", attrs, children) :: elems ->
      inner (add_rule domain @@ parse_rule attrs children) elems
    | E ("assert", attrs, children) :: elems ->
      inner (add_assert domain @@ parse_assert attrs children) elems
    | elem :: elems -> swallow_element inner domain elems elem
  in
  inner domain @@ List.rev elems

let parse_domain attrs children =
  let name = get_attr "name" attrs in
  let data_type = get_attr "type" attrs in
  let label = get_attr_option "label" attrs in
  let domain = Domain.make name data_type label in
  parse_domain_children domain children

let parse_chassis attrs children =
  let name = get_attr "name" attrs in
  let implement = get_attr "implement" attrs in
  let () = consume_children children in
  Chassis.make name implement

let parse_field_children field elems =
  let open Field in
  let rec inner field = function
    | [] -> field
    | E ("rule", attrs, children) :: elems ->
      inner (add_rule field @@ parse_rule attrs children) elems
    | E ("assert", attrs, children) :: elems ->
      inner (add_assert field @@ parse_assert attrs children) elems
    | elem :: elems -> swallow_element inner field elems elem
  in
  inner field @@ List.rev elems

let parse_field attrs children =
  let name = get_attr "name" attrs in
  let domain = get_attr_option "domain" attrs in
  let data_type = get_attr_option "type" attrs in
  let label = get_attr_option "label" attrs in
  let field = Field.make name domain data_type label in
  parse_field_children field children

let parse_response attrs children =
  let name = get_attr "name" attrs in
  let () = consume_children children in
  Response.make name

let parse_method_children meth elems =
  let open Method in
  let rec inner meth = function
    | [] -> meth
    | E ("rule", attrs, children) :: elems ->
      inner (add_rule meth @@ parse_rule attrs children) elems
    | E ("chassis", attrs, children) :: elems ->
      inner (add_chassis meth @@ parse_chassis attrs children) elems
    | E ("response", attrs, children) :: elems ->
      inner (add_response meth @@ parse_response attrs children) elems
    | E ("field", attrs, children) :: elems ->
      inner (add_field meth @@ parse_field attrs children) elems
    | E ("assert", attrs, children) :: elems ->
      inner (add_assert meth @@ parse_assert attrs children) elems
    | elem :: elems -> swallow_element inner meth elems elem
  in
  inner meth @@ List.rev elems

let parse_method attrs children =
  let name = get_attr "name" attrs in
  let index = get_int_attr "index" attrs in
  let synchronous = get_bool_attr "synchronous" attrs in
  let content = get_bool_attr "content" attrs in
  let label = get_attr_option "label" attrs in
  let meth = Method.make name index synchronous content label in
  parse_method_children meth children

let parse_class_children cls elems =
  let open Class in
  let rec inner cls = function
    | [] -> cls
    | E ("chassis", attrs, children) :: elems ->
      inner (add_chassis cls @@ parse_chassis attrs children) elems
    | E ("method", attrs, children) :: elems ->
      inner (add_method cls @@ parse_method attrs children) elems
    | E ("rule", attrs, children) :: elems ->
      inner (add_rule cls @@ parse_rule attrs children) elems
    | E ("field", attrs, children) :: elems ->
      inner (add_field cls @@ parse_field attrs children) elems
    | elem :: elems -> swallow_element inner cls elems elem
  in
  inner cls @@ List.rev elems

let parse_class attrs children =
  let name = get_attr "name" attrs in
  let handler = get_attr "handler" attrs in
  let index = get_int_attr "index" attrs in
  let label = get_attr "label" attrs in
  let cls = Class.make name handler index label in
  parse_class_children cls children

let parse_amqp_children spec elems =
  let open Spec in
  let rec inner spec = function
    | [] -> spec
    | E ("constant", attrs, children) :: elems ->
      inner (add_constant spec @@ parse_constant attrs children) elems
    | E ("domain", attrs, children) :: elems ->
      inner (add_domain spec @@ parse_domain attrs children) elems
    | E ("class", attrs, children) :: elems ->
      inner (add_class spec @@ parse_class attrs children) elems
    | elem :: elems -> swallow_element inner spec elems elem
  in
  inner spec @@ List.rev elems

let parse_amqp attrs children =
  let major = get_int_attr "major" attrs in
  let minor = get_int_attr "minor" attrs in
  let revision = get_int_attr "revision" attrs in
  let comment = get_attr "comment" attrs in
  let spec = Spec.make (major, minor, revision) comment in
  parse_amqp_children spec children

let parse_spec (_dtd, tree) =
  match tree with
  | E ("amqp", attrs, children) -> parse_amqp attrs children
  | _ -> assert false

let parse_spec_from_channel input =
  Xmlm.make_input (`Channel input) |> in_tree |> parse_spec
