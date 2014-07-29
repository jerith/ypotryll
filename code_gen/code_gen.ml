
let print_spec spec =
  Amqp_spec.Spec.fmt Format.std_formatter spec;
  print_newline ()

let () = Spec_parser.parse_spec_from_channel stdin |> print_spec
