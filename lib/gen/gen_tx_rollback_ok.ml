(* This is generated code. *)


module Tx_rollback_ok = struct
  open Protocol

  let class_id = 90
  let method_id = 31

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
