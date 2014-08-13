(* This file is generated. See the code_gen dir for details. *)


module Channel_flow_ok = struct
  open Protocol

  let name = "channel.flow-ok"
  let class_id = 20
  let method_id = 21
  let synchronous = false
  let content = false

  let responses = [
  ]

  type record = {
    active : bool (* bit : bit *);
  }

  let arguments = [
    "active", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "active", Amqp_field.Bit payload.active;
    ]

  let t_from_list fields =
    match fields with
    | [
      "active", Amqp_field.Bit active;
    ] -> {
        active;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~active () =
    `Channel_flow_ok {
      active;
    }
end
