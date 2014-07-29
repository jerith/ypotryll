type xml_tree =
  | E of Xmlm.tag * xml_tree list
  | D of string

let in_tree i =
  let el tag childs = E (tag, childs)  in
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

let fmt_attr ((_, name), value) =
  Printf.sprintf "%s=%S" name value

let fmt_attrs = function
  | [] -> ""
  | attrs -> " " ^ String.concat " " @@ List.map fmt_attr attrs

let fmt_tag ((_, name), attrs) =
  Printf.sprintf "<%s%s>" name (fmt_attrs attrs)

let print_tag tag =
  print_endline @@ fmt_tag tag

let fmt_elem = function
  | E (tag, _) -> fmt_tag tag
  | D string -> Printf.sprintf "%S" string

let print_elem elem =
  print_endline @@ fmt_elem elem

let parse_constant attrs _children =
  let name = get_attr "name" attrs in
  let value = int_of_string @@ get_attr "value" attrs in
  let cls = get_attr_option "class" attrs in
  Amqp_spec.make_constant name value cls

let parse_rule attrs _children =
  let name = get_attr "name" attrs in
  Amqp_spec.make_rule name

let parse_assertion attrs _children =
  Amqp_spec.make_assertion (get_attr "check" attrs) (get_attr_option "value" attrs)

let parse_domain_children elems =
  let rec inner rules assertions = function
    | [] -> (rules, assertions)
    | D _ :: elems -> inner rules assertions elems
    | E (((_, "doc"), _), _) :: elems -> inner rules assertions elems
    | E (((_, "rule"), attrs), children) :: elems ->
      inner ((parse_rule attrs children) :: rules) assertions elems
    | E (((_, "assert"), attrs), children) :: elems ->
      inner rules ((parse_assertion attrs children) :: assertions) elems
    | E (tag, _) :: elems -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag tag))
  in
  inner [] [] elems

let parse_domain attrs children =
  let name = get_attr "name" attrs in
  let data_type = get_attr "type" attrs in
  let label = get_attr_option "label" attrs in
  let rules, assertions = parse_domain_children children in
  Amqp_spec.make_domain name data_type label rules assertions

let parse_chassis attrs children =
  let name = get_attr "name" attrs in
  let implement = get_attr "implement" attrs in
  Amqp_spec.make_chassis name implement

let parse_method attrs children =
  Amqp_spec.make_meth @@ fmt_elem (E ((("", "method"), attrs), children))

let parse_field attrs children =
  Amqp_spec.make_field @@ fmt_elem (E ((("", "field"), attrs), children))

let parse_cls_children elems =
  let rec inner chassiss methods rules fields = function
    | [] -> (chassiss, methods, rules, fields)
    | D _ :: elems -> inner chassiss methods rules fields elems
    | E (((_, "doc"), _), _) :: elems -> inner chassiss methods rules fields elems
    | E (((_, "chassis"), attrs), children) :: elems ->
      inner ((parse_chassis attrs children) :: chassiss) methods rules fields elems
    | E (((_, "method"), attrs), children) :: elems ->
      inner chassiss ((parse_method attrs children) :: methods) rules fields elems
    | E (((_, "rule"), attrs), children) :: elems ->
      inner chassiss methods ((parse_rule attrs children) :: rules) fields elems
    | E (((_, "field"), attrs), children) :: elems ->
      inner chassiss methods rules ((parse_field attrs children) :: fields) elems
    | E (tag, _) :: elems -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag tag))
  in
  inner [] [] [] [] elems

let parse_cls attrs children =
  let name = get_attr "name" attrs in
  let handler = get_attr "handler" attrs in
  let index = int_of_string @@ get_attr "index" attrs in
  let label = get_attr "label" attrs in
  let chassiss, methods, rules, fields = parse_cls_children children in
  Amqp_spec.make_cls name handler index label chassiss methods rules fields

let parse_amqp_children elems =
  let rec inner constants domains classes = function
    | [] -> (constants, domains, classes)
    | D _ :: elems -> inner constants domains classes elems
    | E (((_, "constant"), attrs), children) :: elems ->
      inner ((parse_constant attrs children) :: constants) domains classes elems
    | E (((_, "domain"), attrs), children) :: elems ->
      inner constants ((parse_domain attrs children) :: domains) classes elems
    | E (((_, "class"), attrs), children) :: elems ->
      inner constants domains ((parse_cls attrs children) :: classes) elems
    | E (tag, _) :: elems -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag tag))
  in
  inner [] [] [] elems

let parse_amqp attrs children =
  let major = int_of_string @@ get_attr "major" attrs in
  let minor = int_of_string @@ get_attr "minor" attrs in
  let revision = int_of_string @@ get_attr "revision" attrs in
  let comment = get_attr "comment" attrs in
  let constants, domains, classes = parse_amqp_children children in
  Amqp_spec.make_spec (major, minor, revision) comment constants domains classes

let parse_spec (_dtd, tree) =
  match tree with
  | E (((_, "amqp"), attrs), children) -> parse_amqp attrs children
  | _ -> assert false

let parse_spec_from_channel input =
  Xmlm.make_input (`Channel input) |> in_tree |> parse_spec
