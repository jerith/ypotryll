(* This file is generated. See the code_gen dir for details. *)


module Queue_purge_ok = struct
  open Protocol

  let name = "queue.purge-ok"
  let class_id = 50
  let method_id = 31
  let synchronous = true
  let content = false

  let responses = [
  ]

  type record = {
    message_count : int32 (* message-count : long *);
  }

  let arguments = [
    "message-count", Field_type.Long;
  ]

  let t_to_list payload =
    [
      "message-count", Amqp_field.Long payload.message_count;
    ]

  let t_from_list fields =
    match fields with
    | [
      "message-count", Amqp_field.Long message_count;
    ] -> {
        message_count;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~message_count () =
    `Queue_purge_ok {
      message_count;
    }
end
