(* This file is generated. See the code_gen dir for details. *)


module Exchange_declare = struct
  open Protocol

  let name = "exchange.declare"
  let class_id = 40
  let method_id = 10
  let synchronous = true
  let content = false

  let responses = [
    (40, 11);
  ]

  type record = {
    reserved_1 : int (* reserved : short *);
    exchange : string (* exchange-name : shortstr *);
    type_ : string (* shortstr : shortstr *);
    passive : bool (* bit : bit *);
    durable : bool (* bit : bit *);
    reserved_2 : bool (* reserved : bit *);
    reserved_3 : bool (* reserved : bit *);
    no_wait : bool (* no-wait : bit *);
    arguments : Ypotryll_field_types.Table.t (* table : table *);
  }

  let arguments = [
    "reserved-1", Field_type.Short;
    "exchange", Field_type.Shortstring;
    "type", Field_type.Shortstring;
    "passive", Field_type.Bit;
    "durable", Field_type.Bit;
    "reserved-2", Field_type.Bit;
    "reserved-3", Field_type.Bit;
    "no-wait", Field_type.Bit;
    "arguments", Field_type.Table;
  ]

  let t_to_list payload =
    [
      "reserved-1", Amqp_field.Short payload.reserved_1;
      "exchange", Amqp_field.Shortstring payload.exchange;
      "type", Amqp_field.Shortstring payload.type_;
      "passive", Amqp_field.Bit payload.passive;
      "durable", Amqp_field.Bit payload.durable;
      "reserved-2", Amqp_field.Bit payload.reserved_2;
      "reserved-3", Amqp_field.Bit payload.reserved_3;
      "no-wait", Amqp_field.Bit payload.no_wait;
      "arguments", Amqp_field.Table payload.arguments;
    ]

  let t_from_list fields =
    match fields with
    | [
      "reserved-1", Amqp_field.Short reserved_1;
      "exchange", Amqp_field.Shortstring exchange;
      "type", Amqp_field.Shortstring type_;
      "passive", Amqp_field.Bit passive;
      "durable", Amqp_field.Bit durable;
      "reserved-2", Amqp_field.Bit reserved_2;
      "reserved-3", Amqp_field.Bit reserved_3;
      "no-wait", Amqp_field.Bit no_wait;
      "arguments", Amqp_field.Table arguments;
    ] -> {
        reserved_1;
        exchange;
        type_;
        passive;
        durable;
        reserved_2;
        reserved_3;
        no_wait;
        arguments;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~exchange ~type_ ~passive ~durable ~no_wait ~arguments () =
    `Exchange_declare {
      reserved_1 = 0;
      exchange;
      type_;
      passive;
      durable;
      reserved_2 = false;
      reserved_3 = false;
      no_wait;
      arguments;
    }
end
