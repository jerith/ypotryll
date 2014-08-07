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


module Doc = struct
  type t = {
    doc_type : string option;
    text : string;
  }

  let make doc_type text =
    { doc_type; text }

  let fmt ppf me =
    Format.fprintf ppf "@[<h><doc%a %S>@]"
      (Fmt_utils.fmt_optional_str "type") me.doc_type me.text

  let fmt_list = Fmt_utils.fmt_list "docs" fmt
end


module Constant = struct
  type t = {
    name : string;
    value : int;
    cls : string option;
    docs : Doc.t list;
  }

  let make name value cls =
    { name; value; cls; docs = [] }

  let add_doc me item =
    { me with docs = item :: me.docs }

  let fmt ppf me =
    Format.fprintf ppf "@[<h><constant %s %d%a@ %a>@]"
      me.name me.value (Fmt_utils.fmt_optional_str "class") me.cls
      Doc.fmt_list me.docs

  let fmt_list = Fmt_utils.fmt_list "constants" fmt
end


module Assert = struct
  type t = {
    check : string;
    value : string option;
    meth : string option;
    field : string option;
  }

  let make check value meth field =
    { check; value; meth; field }

  let fmt ppf me =
    Format.fprintf ppf "@[<h><assert %s%a%a%a>@]"
      me.check
      (Fmt_utils.fmt_optional_str "value") me.value
      (Fmt_utils.fmt_optional_str "method") me.meth
      (Fmt_utils.fmt_optional_str "field") me.field

  let fmt_list = Fmt_utils.fmt_list "asserts" fmt
end


module Rule = struct
  type t = {
    name : string;
    on_failure : string option;
    docs : Doc.t list;
  }

  let make name on_failure =
    { name; on_failure; docs = [] }

  let add_doc me item =
    { me with docs = item :: me.docs }

  let fmt ppf me =
    Format.fprintf ppf "@[<h><rule %S%a@ %a>@]"
      me.name (Fmt_utils.fmt_optional_str "on-failure") me.on_failure
      Doc.fmt_list me.docs

  let fmt_list = Fmt_utils.fmt_list "rules" fmt
end


module Domain = struct
  type t = {
    name : string;
    data_type : string;
    label : string option;
    docs : Doc.t list;
    rules : Rule.t list;
    asserts : Assert.t list;
  }

  let make name data_type label =
    { name; data_type; label; docs = []; rules = []; asserts = [] }

  let add_doc me item =
    { me with docs = item :: me.docs }

  let add_rule me item =
    { me with rules = item :: me.rules }

  let add_assert me item =
    { me with asserts = item :: me.asserts }

  let fmt ppf me =
    Format.fprintf ppf "@[<hv 4><domain %s@ type=%S%a@ %a@ %a@ %a>@]"
      me.name me.data_type (Fmt_utils.fmt_optional_str "label") me.label
      Doc.fmt_list me.docs
      Rule.fmt_list me.rules
      Assert.fmt_list me.asserts

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

  let fmt ppf me =
    Format.fprintf ppf "<chassis %s %s implement>" me.name me.implement

  let fmt_list = Fmt_utils.fmt_list "chassis" fmt
end


module Field = struct
  type t = {
    name : string;
    domain : string option;
    data_type : string option;
    label : string option;
    reserved : bool;
    docs : Doc.t list;
    rules : Rule.t list;
    asserts : Assert.t list;
  }

  let make name domain data_type label reserved =
    { name; domain; data_type; label; reserved;
      docs = []; rules = []; asserts = [] }

  let add_doc me item =
    { me with docs = item :: me.docs }

  let add_rule me item =
    { me with rules = item :: me.rules }

  let add_assert me item =
    { me with asserts = item :: me.asserts }

  let fmt ppf me =
    Format.fprintf ppf "@[<hv 4><field %s%a%a%a@ reserved=%B@ %a@ %a@ %a>@]"
      me.name
      (Fmt_utils.fmt_optional_str "domain") me.domain
      (Fmt_utils.fmt_optional_str "type") me.data_type
      (Fmt_utils.fmt_optional_str "label") me.label
      me.reserved
      Doc.fmt_list me.docs
      Rule.fmt_list me.rules
      Assert.fmt_list me.asserts

  let fmt_list = Fmt_utils.fmt_list "fields" fmt
end


module Response = struct
  type t = {
    name : string;
  }

  let make name =
    { name }

  let fmt ppf me =
    Format.fprintf ppf "%S" me.name

  let fmt_list = Fmt_utils.fmt_list "responses" fmt
end


module Method = struct
  type t = {
    name : string;
    index : int;
    synchronous : bool;
    content : bool;
    label : string option;
    deprecated : bool;
    docs : Doc.t list;
    rules : Rule.t list;
    chassis : Chassis.t list;
    responses : Response.t list;
    fields : Field.t list;
    asserts : Assert.t list;
  }

  let make name index synchronous content label deprecated =
    { name; index; synchronous; content; label; deprecated;
      docs = []; rules = []; chassis = []; responses = []; fields = [];
      asserts = [] }

  let add_doc me item =
    { me with docs = item :: me.docs }

  let add_rule me item =
    { me with rules = item :: me.rules }

  let add_chassis me item =
    { me with chassis = item :: me.chassis }

  let add_response me item =
    { me with responses = item :: me.responses }

  let add_field me item =
    { me with fields = item :: me.fields }

  let add_assert me item =
    { me with asserts = item :: me.asserts }

  let fmt ppf me =
    Format.fprintf ppf
      ("@[<hv 4><method %s %d@ synchronous=%B@ content=%B%a@ deprecated=%B" ^^
       "@ %a@ %a@ %a@ %a@ %a@ %a>@]")
      me.name me.index me.synchronous me.content
      (Fmt_utils.fmt_optional_str "label") me.label me.deprecated
      Doc.fmt_list me.docs
      Rule.fmt_list me.rules
      Chassis.fmt_list me.chassis
      Response.fmt_list me.responses
      Field.fmt_list me.fields
      Assert.fmt_list me.asserts

  let fmt_list = Fmt_utils.fmt_list "methods" fmt
end


module Class = struct
  type t = {
    name : string;
    handler : string;
    index : int;
    label : string;
    docs : Doc.t list;
    chassis : Chassis.t list;
    methods : Method.t list;
    rules : Rule.t list;
    fields : Field.t list;
  }

  let make name handler index label =
    { name; handler; index; label;
      docs = []; chassis = []; methods = []; rules = []; fields = [] }

  let add_doc me item =
    { me with docs = item :: me.docs }

  let add_chassis me item =
    { me with chassis = item :: me.chassis }

  let add_method me item =
    { me with methods = item :: me.methods }

  let add_rule me item =
    { me with rules = item :: me.rules }

  let add_field me item =
    { me with fields = item :: me.fields }

  let fmt ppf me =
    Format.fprintf ppf
      "@[<hv 4><class %s (%s) %d@ label=%S@ %a@ %a@ %a@ %a@ %a>@]"
      me.name me.handler me.index me.label
      Doc.fmt_list me.docs
      Chassis.fmt_list me.chassis
      Method.fmt_list me.methods
      Rule.fmt_list me.rules
      Field.fmt_list me.fields

  let fmt_list = Fmt_utils.fmt_list "classes" fmt
end


module Spec = struct
  type spec = {
    version : (int * int * int);
    port : int;
    comment : string;
    constants : Constant.t list;
    domains : Domain.t list;
    classes : Class.t list;
  }

  let add_constant me item =
    { me with constants = item :: me.constants }

  let add_domain me item =
    { me with domains = item :: me.domains }

  let add_class me item =
    { me with classes = item :: me.classes }

  let make version port comment =
    { version; port; comment; constants = []; domains = []; classes = [] }

  let fmt ppf me =
    let fmt_version (major, minor, revision) =
      Printf.sprintf "%d.%d.%d" major minor revision
    in
    Format.fprintf ppf "@[<hv 2>AMQP %s : %s@ %a@ %a@ %a"
      (fmt_version me.version) me.comment
      Constant.fmt_list me.constants
      Domain.fmt_list me.domains
      Class.fmt_list me.classes
end
