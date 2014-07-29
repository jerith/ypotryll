
let fmt_list name formatter ppf list =
  let rec fmt_items = function
    | [] -> ()
    | item :: items -> begin
        Format.fprintf ppf "@;<1 0>%a;" formatter item;
        fmt_items items
      end
  in
  Format.fprintf ppf "@[<hv 2>%s=[" name;
  fmt_items list;
  Format.fprintf ppf "@;<1 -2>@]]"


type constant = {
  name : string;
  value : int;
  cls : string option;
}

let make_constant name value cls =
  { name; value; cls }

let fmt_constant ppf constant =
  let cls = match constant.cls with
    | None -> ""
    | Some cls -> Printf.sprintf " (%s)" cls
  in
  Format.fprintf ppf "@[<4>%s =@ %d%s@]" constant.name constant.value cls


type assertion = {
  check : string;
  value : string option;
}

let make_assertion check value =
  { check; value }

let fmt_assertion ppf assertion =
  let value = match assertion.value with
    | None -> ""
    | Some value -> Printf.sprintf " %S" value
  in
  Format.fprintf ppf "<assert %s%s>" assertion.check value


type rule = {
  name : string;
}

let make_rule name =
  { name }

let fmt_rule ppf rule =
  Format.fprintf ppf "%S" rule.name


type domain = {
  name : string;
  data_type : string;
  label : string option;
  rules : rule list;
  assertions : assertion list;
}

let make_domain name data_type label rules assertions =
  { name; data_type; label; rules; assertions }

let fmt_domain ppf domain =
  let label = match domain.label with
    | None -> ""
    | Some label -> Printf.sprintf " (label=%S)" label
  in
  Format.fprintf ppf "@[<4>%s : %s%s@ @ %a@ @ %a@]"
    domain.name domain.data_type label
    (fmt_list "rules" fmt_rule) domain.rules
    (fmt_list "assertions" fmt_assertion) domain.assertions


type chassis = {
  name : string;
  implement : string;
}

let make_chassis name implement =
  { name; implement }

let fmt_chassis ppf chassis =
  Format.fprintf ppf "%s implement %s" chassis.implement chassis.name


type field = {
  str : string;
}

let make_field str =
  { str }

let fmt_field ppf field =
  Format.fprintf ppf "%s" field.str


type meth = {
  str : string;
}

let make_meth str =
  { str }

let fmt_meth ppf meth =
  Format.fprintf ppf "%s" meth.str


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

let fmt_cls ppf cls =
  Format.fprintf ppf  "@[<hv 4><%s (%s) %d@ label=%S@ %a@ %a@ %a@ %a>@]"
    cls.name cls.handler cls.index cls.label
    (fmt_list "chassis" fmt_chassis) cls.chassiss
    (fmt_list "methods" fmt_meth) cls.methods
    (fmt_list "rules" fmt_rule) cls.rules
    (fmt_list "fields" fmt_field) cls.fields


type spec = {
  version : (int * int * int);
  comment : string;
  constants : constant list;
  domains : domain list;
  classes : cls list;
}

let make_spec version comment constants domains classes =
  { version; comment; constants; domains; classes }

let fmt_spec ppf spec =
  let fmt_version (major, minor, revision) =
    Printf.sprintf "%d.%d.%d" major minor revision
  in
  Format.fprintf ppf "@[<hv 2>AMQP %s : %s@ %a@ %a@ %a"
    (fmt_version spec.version) spec.comment
    (fmt_list "constants" fmt_constant) spec.constants
    (fmt_list "domains" fmt_domain) spec.domains
    (fmt_list "classes" fmt_cls) spec.classes
