(* This file is generated. See the code_gen dir for details. *)


module Queue_declare = struct
  open Protocol

  let class_id = 50
  let method_id = 10

  type record = {
    reserved_1 : int (* short *);
    queue : string (* queue-name : shortstr *);
    passive : bool (* bit : bit *);
    durable : bool (* bit : bit *);
    exclusive : bool (* bit : bit *);
    auto_delete : bool (* bit : bit *);
    no_wait : bool (* no-wait : bit *);
    arguments : Amqp_table.table (* table : table *);
  }

  let arguments = [
    "reserved-1", Field_type.Short;
    "queue", Field_type.Shortstring;
    "passive", Field_type.Bit;
    "durable", Field_type.Bit;
    "exclusive", Field_type.Bit;
    "auto-delete", Field_type.Bit;
    "no-wait", Field_type.Bit;
    "arguments", Field_type.Table;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Short payload.reserved_1;
      "queue", Amqp_field.Shortstring payload.queue;
      "passive", Amqp_field.Bit payload.passive;
      "durable", Amqp_field.Bit payload.durable;
      "exclusive", Amqp_field.Bit payload.exclusive;
      "auto-delete", Amqp_field.Bit payload.auto_delete;
      "no-wait", Amqp_field.Bit payload.no_wait;
      "arguments", Amqp_field.Table payload.arguments;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Short reserved_1;
      "queue", Amqp_field.Shortstring queue;
      "passive", Amqp_field.Bit passive;
      "durable", Amqp_field.Bit durable;
      "exclusive", Amqp_field.Bit exclusive;
      "auto-delete", Amqp_field.Bit auto_delete;
      "no-wait", Amqp_field.Bit no_wait;
      "arguments", Amqp_field.Table arguments;
    ] -> {
        reserved_1;
        queue;
        passive;
        durable;
        exclusive;
        auto_delete;
        no_wait;
        arguments;
      }
    | _ -> failwith "Unexpected fields."
end
