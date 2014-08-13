(* This file is generated. See the code_gen dir for details. *)


module Exchange_delete_ok = struct
  open Protocol

  let name = "exchange.delete-ok"
  let class_id = 40
  let method_id = 21
  let synchronous = true
  let content = false

  let responses = [
  ]

  type record = unit

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
    `Exchange_delete_ok ()
end
