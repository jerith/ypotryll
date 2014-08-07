(* This file is generated. See the code_gen dir for details. *)


module Connection_close_ok = struct
  open Protocol

  let name = "connection.close-ok"
  let class_id = 10
  let method_id = 51
  let synchronous = true

  let responses = [
  ]

  type record = ()

  let arguments = [
  ]

  let t_to_list payload =
    [
    ]

  let t_from_list fields =
    match fields with
    | [
    ] -> ()
    | _ -> failwith "Unexpected fields."

  let make_t () =
    `Connection_close_ok ()
end
