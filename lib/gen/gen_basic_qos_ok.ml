(* This file is generated. See the code_gen dir for details. *)


module Basic_qos_ok = struct
  open Protocol

  let name = "basic.qos-ok"
  let class_id = 60
  let method_id = 11
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
    `Basic_qos_ok ()
end
