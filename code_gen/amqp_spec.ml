module Fmt_utils = struct
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
end


module Constant = struct
  type t = {
    name : string;
    value : int;
    cls : string option;
  }

  let make name value cls =
    { name; value; cls }

  let fmt ppf constant =
    Format.fprintf ppf "@[<h><constant %s %d%a>@]"
      constant.name constant.value (Fmt_utils.fmt_optional_str "class") constant.cls

  let fmt_list = Fmt_utils.fmt_list "constants" fmt
end


module Assert = struct
  type t = {
    check : string;
    value : string option;
  }

  let make check value =
    { check; value }

  let fmt ppf assertion =
    Format.fprintf ppf "@[<h><assert %s%a>@]"
      assertion.check (Fmt_utils.fmt_optional_str "value") assertion.value

  let fmt_list = Fmt_utils.fmt_list "asserts" fmt
end


module Rule = struct
  type t = {
    name : string;
  }

  let make name =
    { name }

  let fmt ppf rule =
    Format.fprintf ppf "%S" rule.name

  let fmt_list = Fmt_utils.fmt_list "rules" fmt
end


module Domain = struct
  type t = {
    name : string;
    data_type : string;
    label : string option;
    rules : Rule.t list;
    asserts : Assert.t list;
  }

  let make name data_type label =
    { name; data_type; label; rules = []; asserts = [] }

  let add_rule domain item =
    { domain with rules = item :: domain.rules }

  let add_assert domain item =
    { domain with asserts = item :: domain.asserts }

  let fmt ppf domain =
    Format.fprintf ppf "@[<hv 4><domain %s@ type=%S%a@ %a@ %a>@]"
      domain.name domain.data_type (Fmt_utils.fmt_optional_str "label") domain.label
      Rule.fmt_list domain.rules
      Assert.fmt_list domain.asserts

  let fmt_list = Fmt_utils.fmt_list "rules" fmt
end


module Chassis = struct
  open Fmt_utils

  type t = {
    name : string;
    implement : string;
  }

  let make name implement =
    { name; implement }

  let fmt ppf chassis =
    Format.fprintf ppf "<chassis %s %s implement>" chassis.name chassis.implement

  let fmt_list = Fmt_utils.fmt_list "chassis" fmt
end


module Field = struct
  type t = {
    name : string;
    domain : string option;
    data_type : string option;
    label : string option;
    rules : Rule.t list;
    asserts : Assert.t list;
  }

  let make name domain data_type label =
    { name; domain; data_type; label; rules = []; asserts = [] }

  let add_rule field item =
    { field with rules = item :: field.rules }

  let add_assert field item =
    { field with asserts = item :: field.asserts }

  let fmt ppf field =
    Format.fprintf ppf "@[<hv 4><field %s%a%a%a@ %a@ %a>@]"
      field.name
      (Fmt_utils.fmt_optional_str "domain") field.domain
      (Fmt_utils.fmt_optional_str "type") field.data_type
      (Fmt_utils.fmt_optional_str "label") field.label
      Rule.fmt_list field.rules
      Assert.fmt_list field.asserts

  let fmt_list = Fmt_utils.fmt_list "fields" fmt
end


module Response = struct
  type t = {
    name : string;
  }

  let make name =
    { name }

  let fmt ppf response =
    Format.fprintf ppf "%S" response.name

  let fmt_list = Fmt_utils.fmt_list "responses" fmt
end


module Method = struct
  type t = {
    name : string;
    index : int;
    synchronous : bool;
    content : bool;
    label : string option;
    rules : Rule.t list;
    chassis : Chassis.t list;
    responses : Response.t list;
    fields : Field.t list;
    asserts : Assert.t list;
  }

  let make name index synchronous content label =
    { name; index; synchronous; content; label; rules = []; chassis = []; responses = [];
      fields = []; asserts = [] }

  let add_rule meth item =
    { meth with rules = item :: meth.rules }

  let add_chassis meth item =
    { meth with chassis = item :: meth.chassis }

  let add_response meth item =
    { meth with responses = item :: meth.responses }

  let add_field meth item =
    { meth with fields = item :: meth.fields }

  let add_assert meth item =
    { meth with asserts = item :: meth.asserts }

  let fmt ppf meth =
    Format.fprintf ppf
      "@[<hv 4><method %s %d@ synchronous=%B@ content=%B%a@ %a@ %a@ %a@ %a@ %a>@]"
      meth.name meth.index meth.synchronous meth.content
      (Fmt_utils.fmt_optional_str "label") meth.label
      Rule.fmt_list meth.rules
      Chassis.fmt_list meth.chassis
      Response.fmt_list meth.responses
      Field.fmt_list meth.fields
      Assert.fmt_list meth.asserts

  let fmt_list = Fmt_utils.fmt_list "methods" fmt
end


module Class = struct
  type t = {
    name : string;
    handler : string;
    index : int;
    label : string;
    chassis : Chassis.t list;
    methods : Method.t list;
    rules : Rule.t list;
    fields : Field.t list;
  }

  let make name handler index label =
    { name; handler; index; label; chassis = []; methods = []; rules = []; fields = [] }

  let add_chassis cls item =
    { cls with chassis = item :: cls.chassis }

  let add_method cls item =
    { cls with methods = item :: cls.methods }

  let add_rule cls item =
    { cls with rules = item :: cls.rules }

  let add_field cls item =
    { cls with fields = item :: cls.fields }

  let fmt ppf cls =
    Format.fprintf ppf "@[<hv 4><class %s (%s) %d@ label=%S@ %a@ %a@ %a@ %a>@]"
      cls.name cls.handler cls.index cls.label
      Chassis.fmt_list cls.chassis
      Method.fmt_list cls.methods
      Rule.fmt_list cls.rules
      Field.fmt_list cls.fields

  let fmt_list = Fmt_utils.fmt_list "classes" fmt
end


module Spec = struct
  type spec = {
    version : (int * int * int);
    comment : string;
    constants : Constant.t list;
    domains : Domain.t list;
    classes : Class.t list;
  }

  let add_constant spec item =
    { spec with constants = item :: spec.constants }

  let add_domain spec item =
    { spec with domains = item :: spec.domains }

  let add_class spec item =
    { spec with classes = item :: spec.classes }

  let make version comment =
    { version; comment; constants = []; domains = []; classes = [] }

  let fmt ppf spec =
    let fmt_version (major, minor, revision) =
      Printf.sprintf "%d.%d.%d" major minor revision
    in
    Format.fprintf ppf "@[<hv 2>AMQP %s : %s@ %a@ %a@ %a"
      (fmt_version spec.version) spec.comment
      Constant.fmt_list spec.constants
      Domain.fmt_list spec.domains
      Class.fmt_list spec.classes
end
