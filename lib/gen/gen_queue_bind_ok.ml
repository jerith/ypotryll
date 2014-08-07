(* This file is generated. See the code_gen dir for details. *)


module Queue_bind_ok = struct
  open Protocol

  let name = "queue.bind-ok"
  let class_id = 50
  let method_id = 21
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
    `Queue_bind_ok ()
end
