(* This file is generated. See the code_gen dir for details. *)


module Connection_start_ok = struct
  open Protocol

  let name = "connection.start-ok"
  let class_id = 10
  let method_id = 11
  let synchronous = true
  let content = false

  let responses = [
  ]

  type record = {
    client_properties : Ypotryll_field_types.Table.t (* peer-properties : table *);
    mechanism : string (* shortstr : shortstr *);
    response : string (* longstr : longstr *);
    locale : string (* shortstr : shortstr *);
  }

  let arguments = [
    "client-properties", Field_type.Table;
    "mechanism", Field_type.Shortstring;
    "response", Field_type.Longstring;
    "locale", Field_type.Shortstring;
  ]

  let t_to_list payload =
    [
      "client-properties", Amqp_field.Table payload.client_properties;
      "mechanism", Amqp_field.Shortstring payload.mechanism;
      "response", Amqp_field.Longstring payload.response;
      "locale", Amqp_field.Shortstring payload.locale;
    ]

  let t_from_list fields =
    match fields with
    | [
      "client-properties", Amqp_field.Table client_properties;
      "mechanism", Amqp_field.Shortstring mechanism;
      "response", Amqp_field.Longstring response;
      "locale", Amqp_field.Shortstring locale;
    ] -> {
        client_properties;
        mechanism;
        response;
        locale;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~client_properties ~mechanism ~response ~locale () =
    `Connection_start_ok {
      client_properties;
      mechanism;
      response;
      locale;
    }
end
