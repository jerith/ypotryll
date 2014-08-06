(* This file is generated. See the code_gen dir for details. *)


module Connection_close = struct
  open Protocol

  let class_id = 10
  let method_id = 50

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
    `Connection_close {
      reply_code;
      reply_text;
      class_id;
      method_id;
    }
end
