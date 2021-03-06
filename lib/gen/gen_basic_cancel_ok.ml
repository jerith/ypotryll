(* This file is generated. See the code_gen dir for details. *)


module Basic_cancel_ok = struct
  open Protocol

  let name = "basic.cancel-ok"
  let class_id = 60
  let method_id = 31
  let synchronous = true
  let content = false

  let responses = [
  ]

  type record = {
    consumer_tag : string (* consumer-tag : shortstr *);
  }

  let arguments = [
    "consumer-tag", Field_type.Shortstring;
  ]

  let t_to_list payload =
    [
      "consumer-tag", Amqp_field.Shortstring payload.consumer_tag;
    ]

  let t_from_list fields =
    match fields with
    | [
      "consumer-tag", Amqp_field.Shortstring consumer_tag;
    ] -> {
        consumer_tag;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~consumer_tag () =
    `Basic_cancel_ok {
      consumer_tag;
    }
end
