(* This is generated code. *)


module Channel_open = struct
  open Protocol

  let class_id = 20
  let method_id = 10

  type record = {
    reserved_1 : string (* shortstr *);
  }

  let arguments = [
    "reserved-1", Field_type.Shortstring;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Shortstring payload.reserved_1;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Shortstring reserved_1;
    ] -> {
        reserved_1;
      }
    | _ -> failwith "Unexpected fields."
end
