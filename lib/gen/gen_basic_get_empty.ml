(* This file is generated. See the code_gen dir for details. *)


module Basic_get_empty = struct
  open Protocol

  let name = "basic.get-empty"
  let class_id = 60
  let method_id = 72
  let synchronous = true
  let content = false

  let responses = [
  ]

  type record = {
    reserved_1 : string (* reserved : shortstr *);
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

  let make_t () =
    `Basic_get_empty {
      reserved_1 = "";
    }
end
