(* This file is generated. See the code_gen dir for details. *)


module Basic_cancel = struct
  open Protocol

  let name = "basic.cancel"
  let class_id = 60
  let method_id = 30
  let synchronous = true
  let content = false

  let responses = [
    (60, 31);
  ]

  type record = {
    consumer_tag : string (* consumer-tag : shortstr *);
    no_wait : bool (* no-wait : bit *);
  }

  let arguments = [
    "consumer-tag", Field_type.Shortstring;
    "no-wait", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "consumer-tag", Amqp_field.Shortstring payload.consumer_tag;
      "no-wait", Amqp_field.Bit payload.no_wait;
    ]

  let t_from_list fields =
    match fields with
    | [
      "consumer-tag", Amqp_field.Shortstring consumer_tag;
      "no-wait", Amqp_field.Bit no_wait;
    ] -> {
        consumer_tag;
        no_wait;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~consumer_tag ~no_wait () =
    `Basic_cancel {
      consumer_tag;
      no_wait;
    }
end
