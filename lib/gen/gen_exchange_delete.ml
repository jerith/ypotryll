(* This file is generated. See the code_gen dir for details. *)


module Exchange_delete = struct
  open Protocol

  let class_id = 40
  let method_id = 20

  type record = {
    reserved_1 : int (* reserved : short *);
    exchange : string (* exchange-name : shortstr *);
    if_unused : bool (* bit : bit *);
    no_wait : bool (* no-wait : bit *);
  }

  let arguments = [
    "reserved-1", Field_type.Short;
    "exchange", Field_type.Shortstring;
    "if-unused", Field_type.Bit;
    "no-wait", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Short payload.reserved_1;
      "exchange", Amqp_field.Shortstring payload.exchange;
      "if-unused", Amqp_field.Bit payload.if_unused;
      "no-wait", Amqp_field.Bit payload.no_wait;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Short reserved_1;
      "exchange", Amqp_field.Shortstring exchange;
      "if-unused", Amqp_field.Bit if_unused;
      "no-wait", Amqp_field.Bit no_wait;
    ] -> {
        reserved_1;
        exchange;
        if_unused;
        no_wait;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~exchange ~if_unused ~no_wait () =
    `Exchange_delete {
      reserved_1 = 0;
      exchange;
      if_unused;
      no_wait;
    }
end
