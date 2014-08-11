(* This file is generated. See the code_gen dir for details. *)


module Basic = struct
  open Protocol

  let name = "basic"
  let class_id = 60

  type record = {
    content_type : string option (* shortstr : shortstr *);
    content_encoding : string option (* shortstr : shortstr *);
    headers : Ypotryll_field_types.Table.t option (* table : table *);
    delivery_mode : int option (* octet : octet *);
    priority : int option (* octet : octet *);
    correlation_id : string option (* shortstr : shortstr *);
    reply_to : string option (* shortstr : shortstr *);
    expiration : string option (* shortstr : shortstr *);
    message_id : string option (* shortstr : shortstr *);
    timestamp : int64 option (* timestamp : timestamp *);
    type_ : string option (* shortstr : shortstr *);
    user_id : string option (* shortstr : shortstr *);
    app_id : string option (* shortstr : shortstr *);
    reserved : string option (* shortstr : shortstr *);
  }

  let properties = [
    "content-type", Field_type.Shortstring;
    "content-encoding", Field_type.Shortstring;
    "headers", Field_type.Table;
    "delivery-mode", Field_type.Octet;
    "priority", Field_type.Octet;
    "correlation-id", Field_type.Shortstring;
    "reply-to", Field_type.Shortstring;
    "expiration", Field_type.Shortstring;
    "message-id", Field_type.Shortstring;
    "timestamp", Field_type.Timestamp;
    "type", Field_type.Shortstring;
    "user-id", Field_type.Shortstring;
    "app-id", Field_type.Shortstring;
    "reserved", Field_type.Shortstring;
  ]

  let t_to_list payload =
    [
      "content-type", maybe (fun x -> Amqp_field.Shortstring x) payload.content_type;
      "content-encoding", maybe (fun x -> Amqp_field.Shortstring x) payload.content_encoding;
      "headers", maybe (fun x -> Amqp_field.Table x) payload.headers;
      "delivery-mode", maybe (fun x -> Amqp_field.Octet x) payload.delivery_mode;
      "priority", maybe (fun x -> Amqp_field.Octet x) payload.priority;
      "correlation-id", maybe (fun x -> Amqp_field.Shortstring x) payload.correlation_id;
      "reply-to", maybe (fun x -> Amqp_field.Shortstring x) payload.reply_to;
      "expiration", maybe (fun x -> Amqp_field.Shortstring x) payload.expiration;
      "message-id", maybe (fun x -> Amqp_field.Shortstring x) payload.message_id;
      "timestamp", maybe (fun x -> Amqp_field.Timestamp x) payload.timestamp;
      "type", maybe (fun x -> Amqp_field.Shortstring x) payload.type_;
      "user-id", maybe (fun x -> Amqp_field.Shortstring x) payload.user_id;
      "app-id", maybe (fun x -> Amqp_field.Shortstring x) payload.app_id;
      "reserved", maybe (fun x -> Amqp_field.Shortstring x) payload.reserved;
    ]

  let t_from_list fields =
    match fields with
    | [
      "content-type", ((None | Some (Amqp_field.Shortstring _)) as content_type);
      "content-encoding", ((None | Some (Amqp_field.Shortstring _)) as content_encoding);
      "headers", ((None | Some (Amqp_field.Table _)) as headers);
      "delivery-mode", ((None | Some (Amqp_field.Octet _)) as delivery_mode);
      "priority", ((None | Some (Amqp_field.Octet _)) as priority);
      "correlation-id", ((None | Some (Amqp_field.Shortstring _)) as correlation_id);
      "reply-to", ((None | Some (Amqp_field.Shortstring _)) as reply_to);
      "expiration", ((None | Some (Amqp_field.Shortstring _)) as expiration);
      "message-id", ((None | Some (Amqp_field.Shortstring _)) as message_id);
      "timestamp", ((None | Some (Amqp_field.Timestamp _)) as timestamp);
      "type", ((None | Some (Amqp_field.Shortstring _)) as type_);
      "user-id", ((None | Some (Amqp_field.Shortstring _)) as user_id);
      "app-id", ((None | Some (Amqp_field.Shortstring _)) as app_id);
      "reserved", ((None | Some (Amqp_field.Shortstring _)) as reserved);
    ] -> {
        content_type = maybe (function Amqp_field.Shortstring x -> x | _ -> assert false) content_type;
        content_encoding = maybe (function Amqp_field.Shortstring x -> x | _ -> assert false) content_encoding;
        headers = maybe (function Amqp_field.Table x -> x | _ -> assert false) headers;
        delivery_mode = maybe (function Amqp_field.Octet x -> x | _ -> assert false) delivery_mode;
        priority = maybe (function Amqp_field.Octet x -> x | _ -> assert false) priority;
        correlation_id = maybe (function Amqp_field.Shortstring x -> x | _ -> assert false) correlation_id;
        reply_to = maybe (function Amqp_field.Shortstring x -> x | _ -> assert false) reply_to;
        expiration = maybe (function Amqp_field.Shortstring x -> x | _ -> assert false) expiration;
        message_id = maybe (function Amqp_field.Shortstring x -> x | _ -> assert false) message_id;
        timestamp = maybe (function Amqp_field.Timestamp x -> x | _ -> assert false) timestamp;
        type_ = maybe (function Amqp_field.Shortstring x -> x | _ -> assert false) type_;
        user_id = maybe (function Amqp_field.Shortstring x -> x | _ -> assert false) user_id;
        app_id = maybe (function Amqp_field.Shortstring x -> x | _ -> assert false) app_id;
        reserved = maybe (function Amqp_field.Shortstring x -> x | _ -> assert false) reserved;
      }
    | _ -> failwith "Unexpected fields."
end
