open Amqp_spec

type xml_tree =
  | E of string * Xmlm.attribute list * xml_tree list
  | D of string

let in_tree i =
  let el ((_, name), attrs) children = E (name, attrs, children)  in
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
  String.concat " " @@ List.map fmt_attr attrs

let fmt_tag name attrs =
  Printf.sprintf "<%s%s>" name (fmt_attrs attrs)

let swallow_element = function
  | D text ->
    if String.trim text = ""
    then ()
    else failwith (Printf.sprintf "Unexpected text: %S" text)
  | E ("doc", _, _) -> ()
  | E (tag, attrs, _) -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag tag attrs))

let consume_children children =
  ignore @@ List.map swallow_element children

let assert_no_attrs = function
  | [] -> ()
  | attrs -> failwith ("Expected empty attr list, got <" ^ (fmt_attrs attrs) ^ ">")


let parse_constant attrs children =
  let attrs, name = consume_attr "name" attrs in
  let attrs, value = consume_int_attr "value" attrs in
  let attrs, cls = consume_attr_option "class" attrs in
  assert_no_attrs attrs;
  let () = consume_children children in
  Constant.make name value cls

let parse_rule attrs children =
  let attrs, name = consume_attr "name" attrs in
  let attrs, on_failure = consume_attr_option "on-failure" attrs in
  assert_no_attrs attrs;
  let () = consume_children children in
  Rule.make name on_failure

let parse_assert attrs children =
  let attrs, check = consume_attr "check" attrs in
  let attrs, value = consume_attr_option "value" attrs in
  let attrs, meth = consume_attr_option "method" attrs in
  let attrs, field = consume_attr_option "field" attrs in
  assert_no_attrs attrs;
  let () = consume_children children in
  Assert.make check value meth field

let parse_domain attrs children =
  let attrs, name = consume_attr "name" attrs in
  let attrs, data_type = consume_attr "type" attrs in
  let attrs, label = consume_attr_option "label" attrs in
  let domain = Domain.make name data_type label in
  let open Domain in
  let rec parse_children domain = function
    | [] -> domain
    | E ("rule", attrs, children) :: elems ->
      parse_children (add_rule domain @@ parse_rule attrs children) elems
    | E ("assert", attrs, children) :: elems ->
      parse_children (add_assert domain @@ parse_assert attrs children) elems
    | elem :: elems -> swallow_element elem; parse_children domain elems
  in
  parse_children domain @@ List.rev children

let parse_chassis attrs children =
  let attrs, name = consume_attr "name" attrs in
  let attrs, implement = consume_attr "implement" attrs in
  assert_no_attrs attrs;
  let () = consume_children children in
  Chassis.make name implement

let parse_field attrs children =
  let attrs, name = consume_attr "name" attrs in
  let attrs, domain = consume_attr_option "domain" attrs in
  let attrs, data_type = consume_attr_option "type" attrs in
  let attrs, label = consume_attr_option "label" attrs in
  let attrs, reserved = consume_bool_attr "reserved" attrs in
  assert_no_attrs attrs;
  let field = Field.make name domain data_type label reserved in
  let open Field in
  let rec parse_children field = function
    | [] -> field
    | E ("rule", attrs, children) :: elems ->
      parse_children (add_rule field @@ parse_rule attrs children) elems
    | E ("assert", attrs, children) :: elems ->
      parse_children (add_assert field @@ parse_assert attrs children) elems
    | elem :: elems -> swallow_element elem; parse_children field elems
  in
  parse_children field @@ List.rev children

let parse_response attrs children =
  let attrs, name = consume_attr "name" attrs in
  assert_no_attrs attrs;
  let () = consume_children children in
  Response.make name

let parse_method attrs children =
  let attrs, name = consume_attr "name" attrs in
  let attrs, index = consume_int_attr "index" attrs in
  let attrs, synchronous = consume_bool_attr "synchronous" attrs in
  let attrs, content = consume_bool_attr "content" attrs in
  let attrs, label = consume_attr_option "label" attrs in
  let attrs, deprecated = consume_bool_attr "deprecated" attrs in
  assert_no_attrs attrs;
  let meth = Method.make name index synchronous content label deprecated in
  let open Method in
  let rec parse_children meth = function
    | [] -> meth
    | E ("rule", attrs, children) :: elems ->
      parse_children (add_rule meth @@ parse_rule attrs children) elems
    | E ("chassis", attrs, children) :: elems ->
      parse_children (add_chassis meth @@ parse_chassis attrs children) elems
    | E ("response", attrs, children) :: elems ->
      parse_children (add_response meth @@ parse_response attrs children) elems
    | E ("field", attrs, children) :: elems ->
      parse_children (add_field meth @@ parse_field attrs children) elems
    | E ("assert", attrs, children) :: elems ->
      parse_children (add_assert meth @@ parse_assert attrs children) elems
    | elem :: elems -> swallow_element elem; parse_children meth elems
  in
  parse_children meth @@ List.rev children

let parse_class attrs children =
  let attrs, name = consume_attr "name" attrs in
  let attrs, handler = consume_attr "handler" attrs in
  let attrs, index = consume_int_attr "index" attrs in
  let attrs, label = consume_attr "label" attrs in
  assert_no_attrs attrs;
  let cls = Class.make name handler index label in
  let open Class in
  let rec parse_children cls = function
    | [] -> cls
    | E ("chassis", attrs, children) :: elems ->
      parse_children (add_chassis cls @@ parse_chassis attrs children) elems
    | E ("method", attrs, children) :: elems ->
      parse_children (add_method cls @@ parse_method attrs children) elems
    | E ("rule", attrs, children) :: elems ->
      parse_children (add_rule cls @@ parse_rule attrs children) elems
    | E ("field", attrs, children) :: elems ->
      parse_children (add_field cls @@ parse_field attrs children) elems
    | elem :: elems -> swallow_element elem; parse_children cls elems
  in
  parse_children cls @@ List.rev children

let parse_amqp attrs children =
  let attrs, major = consume_int_attr "major" attrs in
  let attrs, minor = consume_int_attr "minor" attrs in
  let attrs, revision = consume_int_attr "revision" attrs in
  let attrs, port = consume_int_attr "port" attrs in
  let attrs, comment = consume_attr "comment" attrs in
  assert_no_attrs attrs;
  let spec = Spec.make (major, minor, revision) port comment in
  let open Spec in
  let rec parse_children spec = function
    | [] -> spec
    | E ("constant", attrs, children) :: elems ->
      parse_children (add_constant spec @@ parse_constant attrs children) elems
    | E ("domain", attrs, children) :: elems ->
      parse_children (add_domain spec @@ parse_domain attrs children) elems
    | E ("class", attrs, children) :: elems ->
      parse_children (add_class spec @@ parse_class attrs children) elems
    | elem :: elems -> swallow_element elem; parse_children spec elems
  in
  parse_children spec @@ List.rev children

let parse_spec (_dtd, tree) =
  match tree with
  | E ("amqp", attrs, children) -> parse_amqp attrs children
  | _ -> assert false

let parse_spec_from_channel input =
  Xmlm.make_input (`Channel input) |> in_tree |> parse_spec
