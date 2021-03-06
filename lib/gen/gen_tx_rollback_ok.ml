(* This file is generated. See the code_gen dir for details. *)


module Tx_rollback_ok = struct
  open Protocol

  let name = "tx.rollback-ok"
  let class_id = 90
  let method_id = 31
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
    `Tx_rollback_ok ()
end
