(* This file is generated. See the code_gen dir for details. *)


module Connection_secure = struct
  open Protocol

  let name = "connection.secure"
  let class_id = 10
  let method_id = 20
  let synchronous = true
  let content = false

  let responses = [
    (10, 21);
  ]

  type record = {
    challenge : string (* longstr : longstr *);
  }

  let arguments = [
    "challenge", Field_type.Longstring;
  ]

  let t_to_list payload =
    [
      "challenge", Amqp_field.Longstring payload.challenge;
    ]

  let t_from_list fields =
    match fields with
    | [
      "challenge", Amqp_field.Longstring challenge;
    ] -> {
        challenge;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~challenge () =
    `Connection_secure {
      challenge;
    }
end
