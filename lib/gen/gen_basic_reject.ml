(* This file is generated. See the code_gen dir for details. *)


module Basic_reject = struct
  open Protocol

  let name = "basic.reject"
  let class_id = 60
  let method_id = 90
  let synchronous = false
  let content = false

  let responses = [
  ]

  type record = {
    delivery_tag : int64 (* delivery-tag : longlong *);
    requeue : bool (* bit : bit *);
  }

  let arguments = [
    "delivery-tag", Field_type.Longlong;
    "requeue", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "delivery-tag", Amqp_field.Longlong payload.delivery_tag;
      "requeue", Amqp_field.Bit payload.requeue;
    ]

  let t_from_list fields =
    match fields with
    | [
      "delivery-tag", Amqp_field.Longlong delivery_tag;
      "requeue", Amqp_field.Bit requeue;
    ] -> {
        delivery_tag;
        requeue;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~delivery_tag ~requeue () =
    `Basic_reject {
      delivery_tag;
      requeue;
    }
end
