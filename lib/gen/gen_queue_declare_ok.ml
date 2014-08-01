(* This is generated code. *)


module Queue_declare_ok = struct
  open Protocol

  let class_id = 50
  let method_id = 11

  type record = {
    queue : string (* queue-name : shortstr *);
    message_count : int (* message-count : long *);
    consumer_count : int (* long : long *);
  }

  let arguments = [
    "queue", Field_type.Shortstring;
    "message-count", Field_type.Long;
    "consumer-count", Field_type.Long;
  ]

  let t_to_list payload =
    [
      "queue", Amqp_field.Shortstring payload.queue;
      "message-count", Amqp_field.Long payload.message_count;
      "consumer-count", Amqp_field.Long payload.consumer_count;
    ]

  let t_from_list fields =
    match fields with
    | [
      "queue", Amqp_field.Shortstring queue;
      "message-count", Amqp_field.Long message_count;
      "consumer-count", Amqp_field.Long consumer_count;
    ] -> {
        queue;
        message_count;
        consumer_count;
      }
    | _ -> failwith "Unexpected fields."
end
