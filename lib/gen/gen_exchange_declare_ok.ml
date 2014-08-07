(* This file is generated. See the code_gen dir for details. *)


module Exchange_declare_ok = struct
  open Protocol

  let name = "exchange.declare-ok"
  let class_id = 40
  let method_id = 11
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
    `Exchange_declare_ok ()
end
