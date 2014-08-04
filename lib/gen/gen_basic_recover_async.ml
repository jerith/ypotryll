(* This file is generated. See the code_gen dir for details. *)


module Basic_recover_async = struct
  open Protocol

  let class_id = 60
  let method_id = 100

  type record = {
    requeue : bool (* bit : bit *);
  }

  let arguments = [
    "requeue", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "requeue", Amqp_field.Bit payload.requeue;
    ]

  let t_from_list fields =
    match fields with
    | [
      "requeue", Amqp_field.Bit requeue;
    ] -> {
        requeue;
      }
    | _ -> failwith "Unexpected fields."
end