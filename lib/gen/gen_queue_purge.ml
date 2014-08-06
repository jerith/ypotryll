(* This file is generated. See the code_gen dir for details. *)


module Queue_purge = struct
  open Protocol

  let class_id = 50
  let method_id = 30

  type record = {
    reserved_1 : int (* reserved : short *);
    queue : string (* queue-name : shortstr *);
    no_wait : bool (* no-wait : bit *);
  }

  let arguments = [
    "reserved-1", Field_type.Short;
    "queue", Field_type.Shortstring;
    "no-wait", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Short payload.reserved_1;
      "queue", Amqp_field.Shortstring payload.queue;
      "no-wait", Amqp_field.Bit payload.no_wait;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Short reserved_1;
      "queue", Amqp_field.Shortstring queue;
      "no-wait", Amqp_field.Bit no_wait;
    ] -> {
        reserved_1;
        queue;
        no_wait;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~queue ~no_wait () =
    `Queue_purge {
      reserved_1 = 0;
      queue;
      no_wait;
    }
end
