open Amqp_spec


type method_module = {
  name : string;
  text : string;
}




let make_module_name cls meth =
  String.map (function
      | '-' -> '_'
      | c -> c
    ) @@ Printf.sprintf "%s_%s" cls.Class.name meth.Method.name

let fmt_index_vals ppf (cls, meth) =
  Format.fprintf ppf "@[<v>val class_id = %d@;val method_id = %d@;@]"
    cls.Class.index meth.Method.index

let fmt_method_t ppf (cls, meth) =
  Format.fprintf ppf "@[<v 2>type t = {@;@;<0 -2>}@]"

let fmt_method_body ppf (cls, meth) =
  Format.fprintf ppf "@[<v 2>module %s = struct@;%a@;%a@;<0 -2>end@]"
    (String.capitalize @@ make_module_name cls meth)
    fmt_index_vals (cls, meth)
    fmt_method_t (cls, meth)

let make_method_text cls meth =
  Format.asprintf "@[<v>%s@;@;open Protocol@;@;%a@]"
    "(* This is generated code. *)"
    fmt_method_body (cls, meth)

let build_method cls meth =
  let module_name = make_module_name cls meth in
  {
    name = module_name;
    text = make_method_text cls meth;
  }


let build_methods spec =
  List.iter (fun cls ->
      Printf.printf "Class %S %d\n" cls.Class.name cls.Class.index;
      List.iter (fun meth ->
          Printf.printf "  Method %S %d\n" meth.Method.name meth.Method.index;
        ) cls.Class.methods
    ) spec.Spec.classes;
  let cls = List.hd spec.Spec.classes in
  let meth = List.hd cls.Class.methods in
  print_endline @@ (build_method cls meth).text
