(* This file is generated. See the code_gen dir for details. *)


module Channel_close_ok = struct
  open Protocol

  let name = "channel.close-ok"
  let class_id = 20
  let method_id = 41
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
    `Channel_close_ok ()
end
