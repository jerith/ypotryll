(* This file is generated. See the code_gen dir for details. *)


module Basic_ack = struct
  open Protocol

  let class_id = 60
  let method_id = 80

  type record = {
    delivery_tag : int (* delivery-tag : longlong *);
    multiple : bool (* bit : bit *);
  }

  let arguments = [
    "delivery-tag", Field_type.Longlong;
    "multiple", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "delivery-tag", Amqp_field.Longlong payload.delivery_tag;
      "multiple", Amqp_field.Bit payload.multiple;
    ]

  let t_from_list fields =
    match fields with
    | [
      "delivery-tag", Amqp_field.Longlong delivery_tag;
      "multiple", Amqp_field.Bit multiple;
    ] -> {
        delivery_tag;
        multiple;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~delivery_tag ~multiple () =
    `Basic_ack {
      delivery_tag;
      multiple;
    }
end
