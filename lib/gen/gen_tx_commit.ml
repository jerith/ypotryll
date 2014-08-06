(* This file is generated. See the code_gen dir for details. *)


module Tx_commit = struct
  open Protocol

  let class_id = 90
  let method_id = 20
  let synchronous = true

  let responses = [
    (90, 21);
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
    `Tx_commit ()
end
