(* This file is generated. See the code_gen dir for details. *)


module Tx_select = struct
  open Protocol

  let class_id = 90
  let method_id = 10

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