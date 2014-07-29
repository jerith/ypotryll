
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

let fmt_optional_str name ppf = function
  | None -> ()
  | Some value -> Format.fprintf ppf "@ %s=%S" name value


type constant = {
  name : string;
  value : int;
  cls : string option;
}

let make_constant name value cls =
  { name; value; cls }

let fmt_constant ppf constant =
  Format.fprintf ppf "@[<h><constant %s %d%a>@]"
    constant.name constant.value (fmt_optional_str "class") constant.cls


type assertion = {
  check : string;
  value : string option;
}

let make_assertion check value =
  { check; value }

let fmt_assertion ppf assertion =
  Format.fprintf ppf "@[<h><assert %s%a>@]"
    assertion.check (fmt_optional_str "value") assertion.value


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
  Format.fprintf ppf "@[<hv 4><domain %s@ type=%S%a@ %a@ %a>@]"
    domain.name domain.data_type (fmt_optional_str "label") domain.label
    (fmt_list "rules" fmt_rule) domain.rules
    (fmt_list "assertions" fmt_assertion) domain.assertions


type chassis = {
  name : string;
  implement : string;
}

let make_chassis name implement =
  { name; implement }

let fmt_chassis ppf chassis =
  Format.fprintf ppf "<chassis %s %s implement>" chassis.name chassis.implement


type field = {
  name : string;
  domain : string option;
  data_type : string option;
  label : string option;
  rules : rule list;
  assertions : assertion list;
}

let make_field name domain data_type label rules assertions =
  { name; domain; data_type; label; rules; assertions }

let fmt_field ppf field =
  Format.fprintf ppf "@[<hv 4><field %s%a%a%a@ %a@ %a>@]"
    field.name
    (fmt_optional_str "domain") field.domain
    (fmt_optional_str "type") field.data_type
    (fmt_optional_str "label") field.label
    (fmt_list "rules" fmt_rule) field.rules
    (fmt_list "assertions" fmt_assertion) field.assertions


type response = {
  name : string;
}

let make_response name =
  { name }

let fmt_response ppf response =
  Format.fprintf ppf "%S" response.name


type meth = {
  name : string;
  index : int;
  synchronous : bool;
  content : bool;
  label : string option;
  rules : rule list;
  chassiss : chassis list;
  responses : response list;
  fields : field list;
  assertions : assertion list;
  (* TODO: children *)
}

let make_meth name index synchronous content label rules chassiss responses fields assertions =
  { name; index; synchronous; content; label; rules; chassiss; responses; fields; assertions }

let fmt_meth ppf meth =
  Format.fprintf ppf "@[<hv 4><method %s %d@ synchronous=%B@ content=%B%a@ %a@ %a@ %a@ %a@ %a>@]"
    meth.name meth.index meth.synchronous meth.content
    (fmt_optional_str "label") meth.label
    (fmt_list "rules" fmt_rule) meth.rules
    (fmt_list "chassis" fmt_chassis) meth.chassiss
    (fmt_list "responses" fmt_response) meth.responses
    (fmt_list "fields" fmt_field) meth.fields
    (fmt_list "assertions" fmt_assertion) meth.assertions


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
  Format.fprintf ppf "@[<hv 4><class %s (%s) %d@ label=%S@ %a@ %a@ %a@ %a>@]"
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
