(* This file is generated. See the code_gen dir for details. *)


module Basic_recover_ok = struct
  open Protocol

  let class_id = 60
  let method_id = 111
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
    `Basic_recover_ok ()
end
