(* This file is generated. See the code_gen dir for details. *)


module Basic_get_ok = struct
  open Protocol

  let class_id = 60
  let method_id = 71
  let synchronous = true

  let responses = [
  ]

  type record = {
    delivery_tag : int (* delivery-tag : longlong *);
    redelivered : bool (* redelivered : bit *);
    exchange : string (* exchange-name : shortstr *);
    routing_key : string (* shortstr : shortstr *);
    message_count : int (* message-count : long *);
  }

  let arguments = [
    "delivery-tag", Field_type.Longlong;
    "redelivered", Field_type.Bit;
    "exchange", Field_type.Shortstring;
    "routing-key", Field_type.Shortstring;
    "message-count", Field_type.Long;
  ]

  let t_to_list payload =
    [
      "delivery-tag", Amqp_field.Longlong payload.delivery_tag;
      "redelivered", Amqp_field.Bit payload.redelivered;
      "exchange", Amqp_field.Shortstring payload.exchange;
      "routing-key", Amqp_field.Shortstring payload.routing_key;
      "message-count", Amqp_field.Long payload.message_count;
    ]

  let t_from_list fields =
    match fields with
    | [
      "delivery-tag", Amqp_field.Longlong delivery_tag;
      "redelivered", Amqp_field.Bit redelivered;
      "exchange", Amqp_field.Shortstring exchange;
      "routing-key", Amqp_field.Shortstring routing_key;
      "message-count", Amqp_field.Long message_count;
    ] -> {
        delivery_tag;
        redelivered;
        exchange;
        routing_key;
        message_count;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~delivery_tag ~redelivered ~exchange ~routing_key ~message_count () =
    `Basic_get_ok {
      delivery_tag;
      redelivered;
      exchange;
      routing_key;
      message_count;
    }
end
