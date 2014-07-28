
let fmt_list formatter list =
  Printf.sprintf "[%s]" @@ String.concat "; " @@ List.map formatter list

let fmt_list_nl formatter list =
  match list with
  | [] -> "[]"
  | _ -> Printf.sprintf "[\n  %s;\n]" @@ String.concat ";\n  " @@ List.map formatter list

let fmt_str str = str


module Amqp_spec = struct

  type constant = {
    name : string;
    value : int;
    cls : string option;
  }

  let make_constant name value cls =
    { name; value; cls }

  let fmt_constant constant =
    let cls = match constant.cls with
      | None -> ""
      | Some cls -> Printf.sprintf " (%s)" cls
    in
    Printf.sprintf "%s = %d%s" constant.name constant.value cls

  type assertion = {
    check : string;
    value : string option;
  }

  let make_assertion check value =
    { check; value }

  let fmt_assertion assertion =
    let value = match assertion.value with
      | None -> ""
      | Some value -> Printf.sprintf " %S" value
    in
    Printf.sprintf "<assert %s%s>" assertion.check value

  type domain = {
    name : string;
    data_type : string;
    label : string option;
    rules : string list;
    assertions : assertion list;
  }

  let make_domain name data_type label rules assertions =
    { name; data_type; label; rules; assertions }

  let fmt_rule rule =
    Printf.sprintf "%S" rule

  let fmt_domain domain =
    let label = match domain.label with
      | None -> ""
      | Some label -> Printf.sprintf " (label=%S)" label
    in
    Printf.sprintf "%s : %s%s   rules=%s   assertions=%s"
      domain.name domain.data_type label
      (fmt_list fmt_rule domain.rules)
      (fmt_list fmt_assertion domain.assertions)

  type amqp_spec = {
    version : (int * int * int);
    comment : string;
    constants : constant list;
  }

  let make_spec version comment constants =
    { version; comment; constants }

end


module Spec_xml = struct
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

  let parse_constant (_tag, attrs) _children =
    let name = get_attr "name" attrs in
    let value = int_of_string @@ get_attr "value" attrs in
    let cls = get_attr_option "class" attrs in
    Amqp_spec.make_constant name value cls

  let parse_rule (_tag, attrs) _children =
    get_attr "name" attrs

  let parse_assertion (_tag, attrs) _children =
    Amqp_spec.make_assertion (get_attr "check" attrs) (get_attr_option "value" attrs)

  let parse_domain_children elems =
    let rec inner rules assertions = function
      | [] -> (rules, assertions)
      | D _ :: elems -> inner rules assertions elems
      | E (((_, "doc"), _), _) :: elems -> inner rules assertions elems
      | E (((_, "rule"), _) as tag, children) :: elems ->
        inner ((parse_rule tag children) :: rules) assertions elems
      | E (((_, "assert"), _) as tag, children) :: elems ->
        inner rules ((parse_assertion tag children) :: assertions) elems
      | E (tag, _) :: elems -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag tag))
    in
    inner [] [] elems

  let parse_domain (_tag, attrs) children =
    let name = get_attr "name" attrs in
    let data_type = get_attr "type" attrs in
    let label = get_attr_option "label" attrs in
    let rules, assertions = parse_domain_children children in
    Amqp_spec.make_domain name data_type label rules assertions

  let parse_cls (_tag, attrs) children =
    fmt_elem (E ((("", ""), attrs), children))

  let parse_amqp_children elems =
    let rec inner constants domains classes = function
      | [] -> (constants, domains, classes)
      | D _ :: elems -> inner constants domains classes elems
      | E (((_, "constant"), _) as tag, children) :: elems ->
        inner ((parse_constant tag children) :: constants) domains classes elems
      | E (((_, "domain"), _) as tag, children) :: elems ->
        inner constants ((parse_domain tag children) :: domains) classes elems
      | E (((_, "class"), _) as tag, children) :: elems ->
        inner constants domains ((parse_cls tag children) :: classes) elems
      | E (tag, _) :: elems -> failwith (Printf.sprintf "bad tag: %s" (fmt_tag tag))
    in
    inner [] [] [] elems

  let parse_amqp tag children =
    print_tag tag;
    let constants, domains, classes = parse_amqp_children children in
    Printf.printf "constants: %s\ndomains: %s\nclasses: %s\n"
      (fmt_list_nl Amqp_spec.fmt_constant constants)
      (fmt_list_nl Amqp_spec.fmt_domain domains)
      (fmt_list_nl fmt_str classes)

  let parse_spec (_dtd, tree) =
    match tree with
    | E (((_, "amqp"), _) as tag, children) -> parse_amqp tag children
    | _ -> assert false
end

let () = Spec_xml.in_tree @@ Xmlm.make_input (`Channel stdin) |> Spec_xml.parse_spec
