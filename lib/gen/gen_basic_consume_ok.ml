(* This file is generated. See the code_gen dir for details. *)


module Basic_consume_ok = struct
  open Protocol

  let class_id = 60
  let method_id = 21

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
    `Basic_consume_ok {
      consumer_tag;
    }
end
