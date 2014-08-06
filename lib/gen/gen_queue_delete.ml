(* This file is generated. See the code_gen dir for details. *)


module Queue_delete = struct
  open Protocol

  let class_id = 50
  let method_id = 40

  type record = {
    reserved_1 : int (* short *);
    queue : string (* queue-name : shortstr *);
    if_unused : bool (* bit : bit *);
    if_empty : bool (* bit : bit *);
    no_wait : bool (* no-wait : bit *);
  }

  let arguments = [
    "reserved-1", Field_type.Short;
    "queue", Field_type.Shortstring;
    "if-unused", Field_type.Bit;
    "if-empty", Field_type.Bit;
    "no-wait", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Short payload.reserved_1;
      "queue", Amqp_field.Shortstring payload.queue;
      "if-unused", Amqp_field.Bit payload.if_unused;
      "if-empty", Amqp_field.Bit payload.if_empty;
      "no-wait", Amqp_field.Bit payload.no_wait;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Short reserved_1;
      "queue", Amqp_field.Shortstring queue;
      "if-unused", Amqp_field.Bit if_unused;
      "if-empty", Amqp_field.Bit if_empty;
      "no-wait", Amqp_field.Bit no_wait;
    ] -> {
        reserved_1;
        queue;
        if_unused;
        if_empty;
        no_wait;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~reserved_1 ~queue ~if_unused ~if_empty ~no_wait () =
    `Queue_delete {
      reserved_1;
      queue;
      if_unused;
      if_empty;
      no_wait;
    }
end
