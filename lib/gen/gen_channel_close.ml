(* This file is generated. See the code_gen dir for details. *)


module Channel_close = struct
  open Protocol

  let name = "channel.close"
  let class_id = 20
  let method_id = 40
  let synchronous = true
  let content = false

  let responses = [
    (20, 41);
  ]

  type record = {
    reply_code : int (* reply-code : short *);
    reply_text : string (* reply-text : shortstr *);
    class_id : int (* class-id : short *);
    method_id : int (* method-id : short *);
  }

  let arguments = [
    "reply-code", Field_type.Short;
    "reply-text", Field_type.Shortstring;
    "class-id", Field_type.Short;
    "method-id", Field_type.Short;
  ]

  let t_to_list payload =
    [
      "reply-code", Amqp_field.Short payload.reply_code;
      "reply-text", Amqp_field.Shortstring payload.reply_text;
      "class-id", Amqp_field.Short payload.class_id;
      "method-id", Amqp_field.Short payload.method_id;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reply-code", Amqp_field.Short reply_code;
      "reply-text", Amqp_field.Shortstring reply_text;
      "class-id", Amqp_field.Short class_id;
      "method-id", Amqp_field.Short method_id;
    ] -> {
        reply_code;
        reply_text;
        class_id;
        method_id;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~reply_code ~reply_text ~class_id ~method_id () =
    `Channel_close {
      reply_code;
      reply_text;
      class_id;
      method_id;
    }
end
