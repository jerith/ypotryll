type xml_tree =
  | E of Xmlm.tag * xml_tree list
  | D of string

let in_tree i =
  let el tag children = E (tag, children)  in
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

let rec consume_children = function
  | [] -> ()
  | D _ :: elems -> consume_children elems
  | E (((_, "doc"), _), _) :: elems -> consume_children elems
  | E (tag, _) :: elems -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag tag))


let parse_constant attrs children =
  let name = get_attr "name" attrs in
  let value = get_int_attr "value" attrs in
  let cls = get_attr_option "class" attrs in
  let () = consume_children children in
  Amqp_spec.make_constant name value cls

let parse_rule attrs children =
  let name = get_attr "name" attrs in
  let () = consume_children children in
  Amqp_spec.make_rule name

let parse_assertion attrs children =
  let check = get_attr "check" attrs in
  let value = get_attr_option "value" attrs in
  let () = consume_children children in
  Amqp_spec.make_assertion check value

let parse_domain_children elems =
  let rec inner rules assertions = function
    | [] -> (List.rev rules, List.rev assertions)
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
  let () = consume_children children in
  Amqp_spec.make_chassis name implement

let parse_field_children elems =
  let rec inner rules assertions = function
    | [] -> (List.rev rules, List.rev assertions)
    | D _ :: elems -> inner rules assertions elems
    | E (((_, "doc"), _), _) :: elems -> inner rules assertions elems
    | E (((_, "rule"), attrs), children) :: elems ->
      inner ((parse_rule attrs children) :: rules) assertions elems
    | E (((_, "assert"), attrs), children) :: elems ->
      inner rules ((parse_assertion attrs children) :: assertions) elems
    | E (tag, _) :: elems -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag tag))
  in
  inner [] [] elems

let parse_field attrs children =
  let name = get_attr "name" attrs in
  let domain = get_attr_option "domain" attrs in
  let data_type = get_attr_option "type" attrs in
  let label = get_attr_option "label" attrs in
  let rules, assertions = parse_field_children children in
  Amqp_spec.make_field name domain data_type label rules assertions

let parse_response attrs children =
  let name = get_attr "name" attrs in
  let () = consume_children children in
  Amqp_spec.make_response name

let parse_method_children elems =
  let rec inner rules chassiss responses fields assertions = function
    | [] -> (List.rev rules, List.rev chassiss, List.rev responses, List.rev fields,
             List.rev assertions)
    | D _ :: elems -> inner rules chassiss responses fields assertions elems
    | E (((_, "doc"), _), _) :: elems -> inner rules chassiss responses fields assertions elems
    | E (((_, "rule"), attrs), children) :: elems ->
      inner ((parse_rule attrs children) :: rules) chassiss responses fields assertions elems
    | E (((_, "chassis"), attrs), children) :: elems ->
      inner rules ((parse_chassis attrs children) :: chassiss) responses fields assertions elems
    | E (((_, "response"), attrs), children) :: elems ->
      inner rules chassiss ((parse_response attrs children) :: responses) fields assertions elems
    | E (((_, "field"), attrs), children) :: elems ->
      inner rules chassiss responses ((parse_field attrs children) :: fields) assertions elems
    | E (((_, "assert"), attrs), children) :: elems ->
      inner rules chassiss responses fields ((parse_assertion attrs children) :: assertions) elems

    | E (tag, _) :: elems -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag tag))
  in
  inner [] [] [] [] [] elems

let parse_method attrs children =
  let name = get_attr "name" attrs in
  let index = get_int_attr "index" attrs in
  let synchronous = get_bool_attr "synchronous" attrs in
  let content = get_bool_attr "content" attrs in
  let label = get_attr_option "label" attrs in
  let rules, chassiss, responses, fields, assertions = parse_method_children children in
  Amqp_spec.make_meth
    name index synchronous content label rules chassiss responses fields assertions

let parse_cls_children elems =
  let rec inner chassiss methods rules fields = function
    | [] -> (List.rev chassiss, List.rev methods, List.rev rules, List.rev fields)
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
  let index = get_int_attr "index" attrs in
  let label = get_attr "label" attrs in
  let chassiss, methods, rules, fields = parse_cls_children children in
  Amqp_spec.make_cls name handler index label chassiss methods rules fields

let parse_amqp_children elems =
  let rec inner constants domains classes = function
    | [] -> (List.rev constants, List.rev domains, List.rev classes)
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
  let major = get_int_attr "major" attrs in
  let minor = get_int_attr "minor" attrs in
  let revision = get_int_attr "revision" attrs in
  let comment = get_attr "comment" attrs in
  let constants, domains, classes = parse_amqp_children children in
  Amqp_spec.make_spec (major, minor, revision) comment constants domains classes

let parse_spec (_dtd, tree) =
  match tree with
  | E (((_, "amqp"), attrs), children) -> parse_amqp attrs children
  | _ -> assert false

let parse_spec_from_channel input =
  Xmlm.make_input (`Channel input) |> in_tree |> parse_spec
