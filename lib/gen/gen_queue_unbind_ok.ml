(* This file is generated. See the code_gen dir for details. *)


module Queue_unbind_ok = struct
  open Protocol

  let class_id = 50
  let method_id = 51

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
