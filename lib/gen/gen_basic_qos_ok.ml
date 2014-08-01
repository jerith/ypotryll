(* This is generated code. *)


module Basic_qos_ok = struct
  open Protocol

  let class_id = 60
  let method_id = 11

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
end
