(* This file is generated. See the code_gen dir for details. *)


module Connection_secure_ok = struct
  open Protocol

  let class_id = 10
  let method_id = 21

  type record = {
    response : string (* longstr : longstr *);
  }

  let arguments = [
    "response", Field_type.Longstring;
  ]

  let t_to_list payload =
    [
      "response", Amqp_field.Longstring payload.response;
    ]

  let t_from_list fields =
    match fields with
    | [
      "response", Amqp_field.Longstring response;
    ] -> {
        response;
      }
    | _ -> failwith "Unexpected fields."
end
