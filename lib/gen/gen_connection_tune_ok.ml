(* This file is generated. See the code_gen dir for details. *)


module Connection_tune_ok = struct
  open Protocol

  let name = "connection.tune-ok"
  let class_id = 10
  let method_id = 31
  let synchronous = true

  let responses = [
  ]

  type record = {
    channel_max : int (* short : short *);
    frame_max : int32 (* long : long *);
    heartbeat : int (* short : short *);
  }

  let arguments = [
    "channel-max", Field_type.Short;
    "frame-max", Field_type.Long;
    "heartbeat", Field_type.Short;
  ]

  let t_to_list payload =
    [
      "channel-max", Amqp_field.Short payload.channel_max;
      "frame-max", Amqp_field.Long payload.frame_max;
      "heartbeat", Amqp_field.Short payload.heartbeat;
    ]

  let t_from_list fields =
    match fields with
    | [
      "channel-max", Amqp_field.Short channel_max;
      "frame-max", Amqp_field.Long frame_max;
      "heartbeat", Amqp_field.Short heartbeat;
    ] -> {
        channel_max;
        frame_max;
        heartbeat;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~channel_max ~frame_max ~heartbeat () =
    `Connection_tune_ok {
      channel_max;
      frame_max;
      heartbeat;
    }
end
