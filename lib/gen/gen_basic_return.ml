(* This file is generated. See the code_gen dir for details. *)


module Basic_return = struct
  open Protocol

  let class_id = 60
  let method_id = 50

  type record = {
    reply_code : int (* reply-code : short *);
    reply_text : string (* reply-text : shortstr *);
    exchange : string (* exchange-name : shortstr *);
    routing_key : string (* shortstr : shortstr *);
  }

  let arguments = [
    "reply-code", Field_type.Short;
    "reply-text", Field_type.Shortstring;
    "exchange", Field_type.Shortstring;
    "routing-key", Field_type.Shortstring;
  ]

  let t_to_list payload =
    [
      "reply-code", Amqp_field.Short payload.reply_code;
      "reply-text", Amqp_field.Shortstring payload.reply_text;
      "exchange", Amqp_field.Shortstring payload.exchange;
      "routing-key", Amqp_field.Shortstring payload.routing_key;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reply-code", Amqp_field.Short reply_code;
      "reply-text", Amqp_field.Shortstring reply_text;
      "exchange", Amqp_field.Shortstring exchange;
      "routing-key", Amqp_field.Shortstring routing_key;
    ] -> {
        reply_code;
        reply_text;
        exchange;
        routing_key;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~reply_code ~reply_text ~exchange ~routing_key () =
    `Basic_return {
      reply_code;
      reply_text;
      exchange;
      routing_key;
    }
end
