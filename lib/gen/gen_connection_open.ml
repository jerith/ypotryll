(* This file is generated. See the code_gen dir for details. *)


module Connection_open = struct
  open Protocol

  let class_id = 10
  let method_id = 40

  type record = {
    virtual_host : string (* path : shortstr *);
    reserved_1 : string (* shortstr *);
    reserved_2 : bool (* bit *);
  }

  let arguments = [
    "virtual-host", Field_type.Shortstring;
    "reserved-1", Field_type.Shortstring;
    "reserved-2", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "virtual-host", Amqp_field.Shortstring payload.virtual_host;
      "reserved-1", Amqp_field.Shortstring payload.reserved_1;
      "reserved-2", Amqp_field.Bit payload.reserved_2;
    ]

  let t_from_list fields =
    match fields with
    | [
      "virtual-host", Amqp_field.Shortstring virtual_host;
      "reserved-1", Amqp_field.Shortstring reserved_1;
      "reserved-2", Amqp_field.Bit reserved_2;
    ] -> {
        virtual_host;
        reserved_1;
        reserved_2;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~virtual_host ~reserved_1 ~reserved_2 () =
    `Connection_open {
      virtual_host;
      reserved_1;
      reserved_2;
    }
end
