(* This file is generated. See the code_gen dir for details. *)


module Basic_qos = struct
  open Protocol

  let name = "basic.qos"
  let class_id = 60
  let method_id = 10
  let synchronous = true
  let content = false

  let responses = [
    (60, 11);
  ]

  type record = {
    prefetch_size : int32 (* long : long *);
    prefetch_count : int (* short : short *);
    global : bool (* bit : bit *);
  }

  let arguments = [
    "prefetch-size", Field_type.Long;
    "prefetch-count", Field_type.Short;
    "global", Field_type.Bit;
  ]

  let t_to_list payload =
    [
      "prefetch-size", Amqp_field.Long payload.prefetch_size;
      "prefetch-count", Amqp_field.Short payload.prefetch_count;
      "global", Amqp_field.Bit payload.global;
    ]

  let t_from_list fields =
    match fields with
    | [
      "prefetch-size", Amqp_field.Long prefetch_size;
      "prefetch-count", Amqp_field.Short prefetch_count;
      "global", Amqp_field.Bit global;
    ] -> {
        prefetch_size;
        prefetch_count;
        global;
      }
    | _ -> failwith "Unexpected fields."

  let make_t ~prefetch_size ~prefetch_count ~global () =
    `Basic_qos {
      prefetch_size;
      prefetch_count;
      global;
    }
end
