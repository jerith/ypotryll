
let fmt_list formatter list =
  Printf.sprintf "[%s]" @@ String.concat "; " @@ List.map formatter list

let _fmt_list_nl_depth = ref 0

let fmt_list_nl formatter list =
  match list with
  | [] -> "[]"
  | _ -> begin
      let indent = String.make (!_fmt_list_nl_depth * 2) ' ' in
      _fmt_list_nl_depth := !_fmt_list_nl_depth + 1;
      let items = String.concat (";\n  " ^ indent) @@ List.map formatter list in
      let str = Printf.sprintf "[\n  %s%s;\n%s]" indent items indent in
      _fmt_list_nl_depth := !_fmt_list_nl_depth - 1;
      str
    end


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


type rule = {
  name : string;
}

let make_rule name =
  { name }

let fmt_rule rule =
  Printf.sprintf "%S" rule.name


type domain = {
  name : string;
  data_type : string;
  label : string option;
  rules : rule list;
  assertions : assertion list;
}

let make_domain name data_type label rules assertions =
  { name; data_type; label; rules; assertions }

let fmt_domain domain =
  let label = match domain.label with
    | None -> ""
    | Some label -> Printf.sprintf " (label=%S)" label
  in
  Printf.sprintf "%s : %s%s   rules=%s   assertions=%s"
    domain.name domain.data_type label
    (fmt_list fmt_rule domain.rules)
    (fmt_list fmt_assertion domain.assertions)


type chassis = {
  name : string;
  implement : string;
}

let make_chassis name implement =
  { name; implement }

let fmt_chassis chassis =
  Printf.sprintf "%s implement %s" chassis.implement chassis.name


type field = {
  str : string;
}

let make_field str =
  { str }

let fmt_field field =
  field.str


type meth = {
  str : string;
}

let make_meth str =
  { str }

let fmt_meth meth =
  meth.str


type cls = {
  name : string;
  handler : string;
  index : int;
  label : string;
  chassiss : chassis list;
  methods : meth list;
  rules : rule list;
  fields : field list;
}

let make_cls name handler index label chassiss methods rules fields =
  { name; handler; index; label; chassiss; methods; rules; fields }

let fmt_cls cls =
  Printf.sprintf "<%s (%s) %d label=%S chassis=%s methods=%s rules=%s fields=%s>"
    cls.name cls.handler cls.index cls.label (fmt_list fmt_chassis cls.chassiss)
    (fmt_list_nl fmt_meth cls.methods)
    (fmt_list_nl fmt_rule cls.rules)
    (fmt_list_nl fmt_field cls.fields)


type spec = {
  version : (int * int * int);
  comment : string;
  constants : constant list;
  domains : domain list;
  classes : cls list;
}

let make_spec version comment constants domains classes =
  { version; comment; constants; domains; classes }

let fmt_spec spec =
  let fmt_version (major, minor, revision) =
    Printf.sprintf "%d.%d.%d" major minor revision
  in
  Printf.sprintf "AMQP %s : %s\nconstants: %s\ndomains: %s\nclasses: %s\n"
    (fmt_version spec.version) spec.comment
    (fmt_list_nl fmt_constant spec.constants)
    (fmt_list_nl fmt_domain spec.domains)
    (fmt_list_nl fmt_cls spec.classes)
