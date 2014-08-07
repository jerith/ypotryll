(* This file is generated. See the code_gen dir for details. *)


module Basic_recover = struct
  open Protocol

  let name = "basic.recover"
  let class_id = 60
  let method_id = 110
  let synchronous = false

  let responses = [
  ]

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

  let make_t ~requeue () =
    `Basic_recover {
      requeue;
    }
end
