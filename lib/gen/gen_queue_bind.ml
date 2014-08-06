(* This file is generated. See the code_gen dir for details. *)


module Queue_bind = struct
  open Protocol

  let class_id = 50
  let method_id = 20

  type record = {
    reserved_1 : int (* short *);
    queue : string (* queue-name : shortstr *);
    exchange : string (* exchange-name : shortstr *);
    routing_key : string (* shortstr : shortstr *);
    no_wait : bool (* no-wait : bit *);
    arguments : Amqp_table.table (* table : table *);
  }

  let arguments = [
    "reserved-1", Field_type.Short;
    "queue", Field_type.Shortstring;
    "exchange", Field_type.Shortstring;
    "routing-key", Field_type.Shortstring;
    "no-wait", Field_type.Bit;
    "arguments", Field_type.Table;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Short payload.reserved_1;
      "queue", Amqp_field.Shortstring payload.queue;
      "exchange", Amqp_field.Shortstring payload.exchange;
      "routing-key", Amqp_field.Shortstring payload.routing_key;
      "no-wait", Amqp_field.Bit payload.no_wait;
      "arguments", Amqp_field.Table payload.arguments;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Short reserved_1;
      "queue", Amqp_field.Shortstring queue;
      "exchange", Amqp_field.Shortstring exchange;
      "routing-key", Amqp_field.Shortstring routing_key;
      "no-wait", Amqp_field.Bit no_wait;
      "arguments", Amqp_field.Table arguments;
    ] -> {
        reserved_1;
        queue;
        exchange;
        routing_key;
        no_wait;
        arguments;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~reserved_1 ~queue ~exchange ~routing_key ~no_wait ~arguments () =
    `Queue_bind {
      reserved_1;
      queue;
      exchange;
      routing_key;
      no_wait;
      arguments;
    }
end
