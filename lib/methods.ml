
let parse_unknown_payload buf =
  ["unknown", Protocol.Amqp_field.Unparsed (Parse_utils.consume_str buf @@ Parse_utils.Parse_buf.length buf)]
