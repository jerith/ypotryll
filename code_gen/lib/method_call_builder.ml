open Amqp_spec

open Builder_tools


module Class_caller_module = struct

  type t = {
    name : string;
    text : string;
  }

  let make_arg field =
    match field.Field.reserved with
    | true -> ""
    | false -> "~" ^ make_field_name field ^ " "

  let fmt_async_method_call ppf (spec, cls, meth) =
    let module_name = String.capitalize (make_method_name cls meth) in
    let function_name = name_to_ocaml meth.Method.name in
    let params = match meth.Method.fields with
      | [] -> ""
      | fields -> String.concat "" (List.map make_arg fields)
    in
    let params = params ^ "()" in
    let function_top = function_name ^ " channel " ^ params in
    fmt_function ppf ("let " ^ function_top ^ " =") (fun ppf ->
        Format.fprintf ppf "@,let payload = Ypotryll_methods.%s.make_t %s in"
          module_name params;
        Format.fprintf ppf "@,Connection.send_method_async channel.Connection.channel_io payload")

  let fmt_caller_function ppf (spec, cls, meth) =
    match meth.Method.responses with
    | [] -> fmt_async_method_call ppf (spec, cls, meth)
    | [_] -> Format.fprintf ppf "(* TODO: %s *)" meth.Method.name
    | _ -> Format.fprintf ppf "(* TODO: %s *)" meth.Method.name

  let fmt_caller_module ppf (spec, cls) =
    let module_name = String.capitalize cls.Class.name in
    let fmt_line ppf = Format.fprintf ppf "@;<0 -2>@,%a" in
    fmt_module ppf module_name (fun ppf ->
        List.iter (fun meth -> fmt_line ppf fmt_caller_function (spec, cls, meth))
          cls.Class.methods)

  let make_module_text spec cls =
    Format.fprintf Format.str_formatter "%a" fmt_caller_module (spec, cls);
    Format.flush_str_formatter ()

  let build (spec, cls) =
    make_module_text spec cls

end


let build_class_caller_modules spec =
  let is_channel_class cls = cls.Class.handler = "channel" in
  let channel_classes = List.filter is_channel_class spec.Spec.classes in
  List.map (fun cls -> Class_caller_module.build (spec, cls)) channel_classes
