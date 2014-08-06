(* This file is generated. See the code_gen dir for details. *)


module Basic_publish = struct
  open Protocol

  let class_id = 60
  let method_id = 40

  type record = {
    reserved_1 : int (* short *);
    exchange : string (* exchange-name : shortstr *);
    routing_key : string (* shortstr : shortstr *);
    mandatory : bool (* bit : bit *);
    immediate : bool (* bit : bit *);
  }

  let arguments = [
    "reserved-1", Field_type.Short;
    "exchange", Field_type.Shortstring;
    "routing-key", Field_type.Shortstring;
    "mandatory", Field_type.Bit;
    "immediate", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Short payload.reserved_1;
      "exchange", Amqp_field.Shortstring payload.exchange;
      "routing-key", Amqp_field.Shortstring payload.routing_key;
      "mandatory", Amqp_field.Bit payload.mandatory;
      "immediate", Amqp_field.Bit payload.immediate;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Short reserved_1;
      "exchange", Amqp_field.Shortstring exchange;
      "routing-key", Amqp_field.Shortstring routing_key;
      "mandatory", Amqp_field.Bit mandatory;
      "immediate", Amqp_field.Bit immediate;
    ] -> {
        reserved_1;
        exchange;
        routing_key;
        mandatory;
        immediate;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~reserved_1 ~exchange ~routing_key ~mandatory ~immediate () =
    `Basic_publish {
      reserved_1;
      exchange;
      routing_key;
      mandatory;
      immediate;
    }
end
