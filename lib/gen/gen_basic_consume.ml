(* This file is generated. See the code_gen dir for details. *)


module Basic_consume = struct
  open Protocol

  let name = "basic.consume"
  let class_id = 60
  let method_id = 20
  let synchronous = true
  let content = false

  let responses = [
    (60, 21);
  ]

  type record = {
    reserved_1 : int (* reserved : short *);
    queue : string (* queue-name : shortstr *);
    consumer_tag : string (* consumer-tag : shortstr *);
    no_local : bool (* no-local : bit *);
    no_ack : bool (* no-ack : bit *);
    exclusive : bool (* bit : bit *);
    no_wait : bool (* no-wait : bit *);
    arguments : Ypotryll_field_types.Table.t (* table : table *);
  }

  let arguments = [
    "reserved-1", Field_type.Short;
    "queue", Field_type.Shortstring;
    "consumer-tag", Field_type.Shortstring;
    "no-local", Field_type.Bit;
    "no-ack", Field_type.Bit;
    "exclusive", Field_type.Bit;
    "no-wait", Field_type.Bit;
    "arguments", Field_type.Table;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Short payload.reserved_1;
      "queue", Amqp_field.Shortstring payload.queue;
      "consumer-tag", Amqp_field.Shortstring payload.consumer_tag;
      "no-local", Amqp_field.Bit payload.no_local;
      "no-ack", Amqp_field.Bit payload.no_ack;
      "exclusive", Amqp_field.Bit payload.exclusive;
      "no-wait", Amqp_field.Bit payload.no_wait;
      "arguments", Amqp_field.Table payload.arguments;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Short reserved_1;
      "queue", Amqp_field.Shortstring queue;
      "consumer-tag", Amqp_field.Shortstring consumer_tag;
      "no-local", Amqp_field.Bit no_local;
      "no-ack", Amqp_field.Bit no_ack;
      "exclusive", Amqp_field.Bit exclusive;
      "no-wait", Amqp_field.Bit no_wait;
      "arguments", Amqp_field.Table arguments;
    ] -> {
        reserved_1;
        queue;
        consumer_tag;
        no_local;
        no_ack;
        exclusive;
        no_wait;
        arguments;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~queue ~consumer_tag ~no_local ~no_ack ~exclusive ~no_wait ~arguments () =
    `Basic_consume {
      reserved_1 = 0;
      queue;
      consumer_tag;
      no_local;
      no_ack;
      exclusive;
      no_wait;
      arguments;
    }
end
