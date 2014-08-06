(* This file is generated. See the code_gen dir for details. *)


module Channel_open_ok = struct
  open Protocol

  let class_id = 20
  let method_id = 11

  type record = {
    reserved_1 : string (* reserved : longstr *);
  }

  let arguments = [
    "reserved-1", Field_type.Longstring;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Longstring payload.reserved_1;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Longstring reserved_1;
    ] -> {
        reserved_1;
      }
    | _ -> failwith "Unexpected fields."

  let make_t () =
    `Channel_open_ok {
      reserved_1 = "";
    }
end
