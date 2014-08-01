open Amqp_spec

type xml_tree =
  | E of string * (Xmlm.attribute list * xml_tree list)
  | D of string

let in_tree i =
  let el ((_, name), attrs) children = E (name, (attrs, children))  in
  let data d = D d in
  Xmlm.input_doc_tree ~el ~data i


let consume_attr_option name attrs =
  let rec walk_attrs walked = function
    | [] -> (List.rev walked, None)
    | ((_, attr_name), value) as attr :: attrs ->
      if attr_name = name
      then ((List.rev walked) @ attrs, Some value)
      else walk_attrs (attr :: walked) attrs
  in
  walk_attrs [] attrs

let consume_attr name attrs =
  match consume_attr_option name attrs with
  | _attrs, None -> failwith ("Attr not found: " ^ name)
  | attrs, Some value -> (attrs, value)

let consume_bool_attr name attrs =
  match consume_attr_option name attrs with
  | attrs, None -> attrs, false
  | attrs, Some "1" -> attrs, true
  | _attrs, Some value -> failwith ("Unexpected boolean attr value: " ^ value)

let consume_int_attr name attrs =
  let attrs, value = consume_attr name attrs in
  attrs, int_of_string value

let fmt_attrs attrs =
  let fmt_attr ((_, name), value) =
    Printf.sprintf "%s=%S" name value
  in
  " " ^ String.concat " " (List.map fmt_attr attrs)

let fmt_tag name (attrs, _children) =
  Printf.sprintf "<%s%s>" name (fmt_attrs attrs)

let swallow_element = function
  | D text ->
    if String.trim text = ""
    then ()
    else failwith (Printf.sprintf "Unexpected text: %S" text)
  | E (name, elem) -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag name elem))

let consume_children children =
  ignore (List.map swallow_element children)

let assert_no_attrs = function
  | [] -> ()
  | attrs -> failwith ("Expected empty attr list, got <" ^ (fmt_attrs attrs) ^ ">")


let parse_doc (attrs, children) =
  let attrs, doc_type = consume_attr_option "type" attrs in
  assert_no_attrs attrs;
  let text = match children with
    | [D text] -> text
    | _ -> failwith "Unexpected children in doc tag."
  in
  Doc.make doc_type text

let parse_constant (attrs, children) =
  let attrs, name = consume_attr "name" attrs in
  let attrs, value = consume_int_attr "value" attrs in
  let attrs, cls = consume_attr_option "class" attrs in
  assert_no_attrs attrs;
  let me = Constant.make name value cls in
  let open Constant in
  let rec fill me = function
    | [] -> me
    | E ("doc", elem) :: elems -> fill (add_doc me (parse_doc elem)) elems
    | elem :: elems -> swallow_element elem; fill me elems
  in
  fill me (List.rev children)

let parse_rule (attrs, children) =
  let attrs, name = consume_attr "name" attrs in
  let attrs, on_failure = consume_attr_option "on-failure" attrs in
  assert_no_attrs attrs;
  let me = Rule.make name on_failure in
  let open Rule in
  let rec fill me = function
    | [] -> me
    | E ("doc", elem) :: elems -> fill (add_doc me (parse_doc elem)) elems
    | elem :: elems -> swallow_element elem; fill me elems
  in
  fill me (List.rev children)

let parse_assert (attrs, children) =
  let attrs, check = consume_attr "check" attrs in
  let attrs, value = consume_attr_option "value" attrs in
  let attrs, meth = consume_attr_option "method" attrs in
  let attrs, field = consume_attr_option "field" attrs in
  assert_no_attrs attrs;
  let () = consume_children children in
  Assert.make check value meth field

let parse_domain (attrs, children) =
  let attrs, name = consume_attr "name" attrs in
  let attrs, data_type = consume_attr "type" attrs in
  let attrs, label = consume_attr_option "label" attrs in
  let me = Domain.make name data_type label in
  let open Domain in
  let rec fill me = function
    | [] -> me
    | E ("doc", elem) :: elems -> fill (add_doc me (parse_doc elem)) elems
    | E ("rule", elem) :: elems -> fill (add_rule me (parse_rule elem)) elems
    | E ("assert", elem) :: elems -> fill (add_assert me (parse_assert elem)) elems
    | elem :: elems -> swallow_element elem; fill me elems
  in
  fill me (List.rev children)

let parse_chassis (attrs, children) =
  let attrs, name = consume_attr "name" attrs in
  let attrs, implement = consume_attr "implement" attrs in
  assert_no_attrs attrs;
  let () = consume_children children in
  Chassis.make name implement

let parse_field (attrs, children) =
  let attrs, name = consume_attr "name" attrs in
  let attrs, domain = consume_attr_option "domain" attrs in
  let attrs, data_type = consume_attr_option "type" attrs in
  let attrs, label = consume_attr_option "label" attrs in
  let attrs, reserved = consume_bool_attr "reserved" attrs in
  assert_no_attrs attrs;
  let me = Field.make name domain data_type label reserved in
  let open Field in
  let rec fill me = function
    | [] -> me
    | E ("doc", elem) :: elems -> fill (add_doc me (parse_doc elem)) elems
    | E ("rule", elem) :: elems -> fill (add_rule me (parse_rule elem)) elems
    | E ("assert", elem) :: elems -> fill (add_assert me (parse_assert elem)) elems
    | elem :: elems -> swallow_element elem; fill me elems
  in
  fill me (List.rev children)

let parse_response (attrs, children) =
  let attrs, name = consume_attr "name" attrs in
  assert_no_attrs attrs;
  let () = consume_children children in
  Response.make name

let parse_method (attrs, children) =
  let attrs, name = consume_attr "name" attrs in
  let attrs, index = consume_int_attr "index" attrs in
  let attrs, synchronous = consume_bool_attr "synchronous" attrs in
  let attrs, content = consume_bool_attr "content" attrs in
  let attrs, label = consume_attr_option "label" attrs in
  let attrs, deprecated = consume_bool_attr "deprecated" attrs in
  assert_no_attrs attrs;
  let me = Method.make name index synchronous content label deprecated in
  let open Method in
  let rec fill me = function
    | [] -> me
    | E ("doc", elem) :: elems -> fill (add_doc me (parse_doc elem)) elems
    | E ("rule", elem) :: elems -> fill (add_rule me (parse_rule elem)) elems
    | E ("chassis", elem) :: elems -> fill (add_chassis me (parse_chassis elem)) elems
    | E ("response", elem) :: elems -> fill (add_response me (parse_response elem)) elems
    | E ("field", elem) :: elems -> fill (add_field me (parse_field elem)) elems
    | E ("assert", elem) :: elems -> fill (add_assert me (parse_assert elem)) elems
    | elem :: elems -> swallow_element elem; fill me elems
  in
  fill me (List.rev children)

let parse_class (attrs, children) =
  let attrs, name = consume_attr "name" attrs in
  let attrs, handler = consume_attr "handler" attrs in
  let attrs, index = consume_int_attr "index" attrs in
  let attrs, label = consume_attr "label" attrs in
  assert_no_attrs attrs;
  let me = Class.make name handler index label in
  let open Class in
  let rec fill me = function
    | [] -> me
    | E ("doc", elem) :: elems -> fill (add_doc me (parse_doc elem)) elems
    | E ("chassis", elem) :: elems -> fill (add_chassis me (parse_chassis elem)) elems
    | E ("method", elem) :: elems -> fill (add_method me (parse_method elem)) elems
    | E ("rule", elem) :: elems -> fill (add_rule me (parse_rule elem)) elems
    | E ("field", elem) :: elems -> fill (add_field me (parse_field elem)) elems
    | elem :: elems -> swallow_element elem; fill me elems
  in
  fill me (List.rev children)

let parse_amqp (attrs, children) =
  let attrs, major = consume_int_attr "major" attrs in
  let attrs, minor = consume_int_attr "minor" attrs in
  let attrs, revision = consume_int_attr "revision" attrs in
  let attrs, port = consume_int_attr "port" attrs in
  let attrs, comment = consume_attr "comment" attrs in
  assert_no_attrs attrs;
  let me = Spec.make (major, minor, revision) port comment in
  let open Spec in
  let rec fill me = function
    | [] -> me
    | E ("constant", elem) :: elems -> fill (add_constant me (parse_constant elem)) elems
    | E ("domain", elem) :: elems -> fill (add_domain me (parse_domain elem)) elems
    | E ("class", elem) :: elems -> fill (add_class me (parse_class elem)) elems
    | elem :: elems -> swallow_element elem; fill me elems
  in
  fill me (List.rev children)

let parse_spec (_dtd, tree) =
  match tree with
  | E ("amqp", elem) -> parse_amqp elem
  | _ -> failwith "Root element is not <amqp> tag. Is this an AMQP spec?"

let parse_spec_from_channel input =
  try
    parse_spec (in_tree (Xmlm.make_input (`Channel input)))
  with
  | Xmlm.Error ((x, y), err) -> failwith (
      Printf.sprintf "XML error at line %d char %d: %s" x y (Xmlm.error_message err))
