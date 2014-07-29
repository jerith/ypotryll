
let () = Spec_parser.parse_spec_from_channel stdin |> Amqp_spec.fmt_spec |> print_endline
