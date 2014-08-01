(* This file is generated. See the code_gen dir for details. *)


module Queue_unbind = struct
  open Protocol

  let class_id = 50
  let method_id = 50

  type record = {
    reserved_1 : int (* short *);
    queue : string (* queue-name : shortstr *);
    exchange : string (* exchange-name : shortstr *);
    routing_key : string (* shortstr : shortstr *);
    arguments : Amqp_table.table (* table : table *);
  }

  let arguments = [
    "reserved-1", Field_type.Short;
    "queue", Field_type.Shortstring;
    "exchange", Field_type.Shortstring;
    "routing-key", Field_type.Shortstring;
    "arguments", Field_type.Table;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Short payload.reserved_1;
      "queue", Amqp_field.Shortstring payload.queue;
      "exchange", Amqp_field.Shortstring payload.exchange;
      "routing-key", Amqp_field.Shortstring payload.routing_key;
      "arguments", Amqp_field.Table payload.arguments;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Short reserved_1;
      "queue", Amqp_field.Shortstring queue;
      "exchange", Amqp_field.Shortstring exchange;
      "routing-key", Amqp_field.Shortstring routing_key;
      "arguments", Amqp_field.Table arguments;
    ] -> {
        reserved_1;
        queue;
        exchange;
        routing_key;
        arguments;
      }
    | _ -> failwith "Unexpected fields."
end
