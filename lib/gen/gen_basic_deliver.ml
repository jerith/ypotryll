(* This file is generated. See the code_gen dir for details. *)


module Basic_deliver = struct
  open Protocol

  let name = "basic.deliver"
  let class_id = 60
  let method_id = 60
  let synchronous = false
  let content = true

  let responses = [
  ]

  type record = {
    consumer_tag : string (* consumer-tag : shortstr *);
    delivery_tag : int64 (* delivery-tag : longlong *);
    redelivered : bool (* redelivered : bit *);
    exchange : string (* exchange-name : shortstr *);
    routing_key : string (* shortstr : shortstr *);
  }

  let arguments = [
    "consumer-tag", Field_type.Shortstring;
    "delivery-tag", Field_type.Longlong;
    "redelivered", Field_type.Bit;
    "exchange", Field_type.Shortstring;
    "routing-key", Field_type.Shortstring;
  ]

  let t_to_list payload =
    [
      "consumer-tag", Amqp_field.Shortstring payload.consumer_tag;
      "delivery-tag", Amqp_field.Longlong payload.delivery_tag;
      "redelivered", Amqp_field.Bit payload.redelivered;
      "exchange", Amqp_field.Shortstring payload.exchange;
      "routing-key", Amqp_field.Shortstring payload.routing_key;
    ]

  let t_from_list fields =
    match fields with
    | [
      "consumer-tag", Amqp_field.Shortstring consumer_tag;
      "delivery-tag", Amqp_field.Longlong delivery_tag;
      "redelivered", Amqp_field.Bit redelivered;
      "exchange", Amqp_field.Shortstring exchange;
      "routing-key", Amqp_field.Shortstring routing_key;
    ] -> {
        consumer_tag;
        delivery_tag;
        redelivered;
        exchange;
        routing_key;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~consumer_tag ~delivery_tag ~redelivered ~exchange ~routing_key () =
    `Basic_deliver {
      consumer_tag;
      delivery_tag;
      redelivered;
      exchange;
      routing_key;
    }
end
