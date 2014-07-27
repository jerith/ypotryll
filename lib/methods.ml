

module Connection_start_definition : Method.Amqp_method_payload_definition = struct
  let class_id = 10
  let method_id = 10

  let arguments = [
    "version-major", Method.Field_type.Octet;
    "version-minor", Method.Field_type.Octet;
    "server-properties", Method.Field_type.Table;
    "mechanisms", Method.Field_type.Longstring;
    "locales", Method.Field_type.Longstring;
  ]

  type t = {
    version_major : int;
    version_minor : int;
    server_properties : Method.Amqp_field.table;
    mechanisms : string;
    locales : string;
  }

  let t_to_list payload =
    [
      "version-major", Method.Amqp_field.Octet payload.version_major;
      "version-minor", Method.Amqp_field.Octet payload.version_minor;
      "server-properties", Method.Amqp_field.Table payload.server_properties;
      "mechanisms", Method.Amqp_field.Longstring payload.mechanisms;
      "locales", Method.Amqp_field.Longstring payload.locales;
    ]

  let t_from_list fields =
    match fields with
    | [
      "version-major", Method.Amqp_field.Octet version_major;
      "version-minor", Method.Amqp_field.Octet version_minor;
      "server-properties", Method.Amqp_field.Table server_properties;
      "mechanisms", Method.Amqp_field.Longstring mechanisms;
      "locales", Method.Amqp_field.Longstring locales;
    ] -> {
        version_major;
        version_minor;
        server_properties;
        mechanisms;
        locales;
      }
    | _ -> failwith "Unexpected fields."
end

let parse_unknown_payload buf =
  ["unknown", Method.Amqp_field.Unparsed (Parse_utils.consume_str buf @@ Parse_utils.Parse_buf.length buf)]

let method_modules = [
  (10, 10), (module Method.Make_method_payload(Connection_start_definition) : Method.Amqp_method_payload);
]
