(* This file is generated. See the code_gen dir for details. *)


module Queue_purge_ok = struct
  open Protocol

  let class_id = 50
  let method_id = 31

  type record = {
    message_count : int (* message-count : long *);
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
end
