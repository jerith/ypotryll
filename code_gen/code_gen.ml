

let spec = Spec_parser.parse_spec_from_channel stdin

let () = Module_builder.build_methods spec

let () = print_endline (Stub_builder.build_stubs ())

let () = Module_builder.build_method_wrappers spec
