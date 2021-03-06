(* This file is generated. See the code_gen dir for details. *)


module Connection_start = struct
  open Protocol

  let name = "connection.start"
  let class_id = 10
  let method_id = 10
  let synchronous = true
  let content = false

  let responses = [
    (10, 11);
  ]

  type record = {
    version_major : int (* octet : octet *);
    version_minor : int (* octet : octet *);
    server_properties : Ypotryll_field_types.Table.t (* peer-properties : table *);
    mechanisms : string (* longstr : longstr *);
    locales : string (* longstr : longstr *);
  }

  let arguments = [
    "version-major", Field_type.Octet;
    "version-minor", Field_type.Octet;
    "server-properties", Field_type.Table;
    "mechanisms", Field_type.Longstring;
    "locales", Field_type.Longstring;
  ]

  let t_to_list payload =
    [
      "version-major", Amqp_field.Octet payload.version_major;
      "version-minor", Amqp_field.Octet payload.version_minor;
      "server-properties", Amqp_field.Table payload.server_properties;
      "mechanisms", Amqp_field.Longstring payload.mechanisms;
      "locales", Amqp_field.Longstring payload.locales;
    ]

  let t_from_list fields =
    match fields with
    | [
      "version-major", Amqp_field.Octet version_major;
      "version-minor", Amqp_field.Octet version_minor;
      "server-properties", Amqp_field.Table server_properties;
      "mechanisms", Amqp_field.Longstring mechanisms;
      "locales", Amqp_field.Longstring locales;
    ] -> {
        version_major;
        version_minor;
        server_properties;
        mechanisms;
        locales;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~version_major ~version_minor ~server_properties ~mechanisms ~locales () =
    `Connection_start {
      version_major;
      version_minor;
      server_properties;
      mechanisms;
      locales;
    }
end
