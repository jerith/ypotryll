(* This file is generated. See the code_gen dir for details. *)


module Basic_get = struct
  open Protocol

  let name = "basic.get"
  let class_id = 60
  let method_id = 70
  let synchronous = true
  let content = false

  let responses = [
    (60, 71);
    (60, 72);
  ]

  type record = {
    reserved_1 : int (* reserved : short *);
    queue : string (* queue-name : shortstr *);
    no_ack : bool (* no-ack : bit *);
  }

  let arguments = [
    "reserved-1", Field_type.Short;
    "queue", Field_type.Shortstring;
    "no-ack", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Short payload.reserved_1;
      "queue", Amqp_field.Shortstring payload.queue;
      "no-ack", Amqp_field.Bit payload.no_ack;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Short reserved_1;
      "queue", Amqp_field.Shortstring queue;
      "no-ack", Amqp_field.Bit no_ack;
    ] -> {
        reserved_1;
        queue;
        no_ack;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~queue ~no_ack () =
    `Basic_get {
      reserved_1 = 0;
      queue;
      no_ack;
    }
end
