(* TODO: Generate this code. *)

open Protocol


module Connection_start = struct
  let class_id = 10
  let method_id = 10

  type record = {
    version_major : int;
    version_minor : int;
    server_properties : Amqp_table.table;
    mechanisms : string;
    locales : string;
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
end
