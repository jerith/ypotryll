

type frame_type =
  | Method
  | Header
  | Body
  | Heartbeat

type method_payload = {
  class_id : int;
  method_id : int;
  arguments : (string * Protocol.Amqp_field.t) list; (* TODO: Determine if this is what we want. *)
}

type frame_payload =
  | Method_p of method_payload
  | Header_p of string
  | Body_p of string
  | Heartbeat_p of string

type frame = {
  frame_type : frame_type;
  channel : int;
  size : int;
  payload : frame_payload;
}

let minimum_frame_length = 8


open Parse_utils

(* String formatting *)

let frame_type_to_string = function
  | Method    -> "Method"
  | Header    -> "Header"
  | Body      -> "Body"
  | Heartbeat -> "Heartbeat"

let rec field_table_to_string field_table =
  Printf.sprintf "{%s}" @@ String.concat "; " (List.map field_entry_to_string field_table)

and field_entry_to_string (name, field_value) =
  let open Protocol.Amqp_table in
  match field_value with
  | Boolean value         -> Printf.sprintf "<Boolean %s=%b>" name value
  | Shortshort_int value  -> Printf.sprintf "<Shortshort_int %s=%d>" name value
  | Shortshort_uint value -> Printf.sprintf "<Shortshort_uint %s=%d>" name value
  | Short_int value       -> Printf.sprintf "<Short_int %s=%d>" name value
  | Short_uint value      -> Printf.sprintf "<Short_uint %s=%d>" name value
  | Long_int value        -> Printf.sprintf "<Long_int %s=%d>" name value
  | Long_uint value       -> Printf.sprintf "<Long_uint %s=%d>" name value
  | Longlong_int value    -> Printf.sprintf "<Longlong_int %s=%d>" name value
  | Longlong_uint value   -> Printf.sprintf "<Longlong_uint %s=%d>" name value
  | Float value           -> Printf.sprintf "<Float %s=%f>" name value
  | Double value          -> Printf.sprintf "<Double %s=%f>" name value
  (* | Decimal value         -> "???" *)
  | Short_string value    -> Printf.sprintf "<Short_string %s=%S>" name value
  | Long_string value     -> Printf.sprintf "<Long_string %s=%S>" name value
  (* | Field_array value     -> "???" *)
  | Timestamp value       -> Printf.sprintf "<Timestamp %s=%d>" name value
  | Field_table value     -> Printf.sprintf "<Field_table %s=%s>" name (field_table_to_string value)
  | No_value              -> Printf.sprintf "<No_value %s>" name

let amqp_field_to_string (name, field) =
  let open Protocol.Amqp_field in
  match field with
  | Octet value       -> Printf.sprintf "<Octet %s %d>" name value
  | Short value       -> Printf.sprintf "<Short %s %d>" name value
  | Long value        -> Printf.sprintf "<Long %s %d>" name value
  | Longlong value    -> Printf.sprintf "<LongLong %s %d>" name value
  | Bit value         -> Printf.sprintf "<Bit %s %b>" name value
  | Shortstring value -> Printf.sprintf "<Shortstring %s %S>" name value
  | Longstring value  -> Printf.sprintf "<Longstring %s %S>" name value
  | Timestamp value   -> Printf.sprintf "<Timestamp %s %d>" name value
  | Table value       -> Printf.sprintf "<Table %s %s>" name (field_table_to_string value)
  | Unparsed value    -> Printf.sprintf "<Unparsed %s %S>" name value (* TODO: Kill this when we parse all payloads. *)

let method_args_to_string args =
  Printf.sprintf "[%s]" @@ String.concat "; " (List.map amqp_field_to_string args)

let frame_payload_to_string = function
  | Method_p payload -> Printf.sprintf "<class=%d method=%d %s>"
                          payload.class_id payload.method_id (method_args_to_string payload.arguments)
  | Header_p payload -> Printf.sprintf "%S" payload
  | Body_p payload -> Printf.sprintf "%S" payload
  | Heartbeat_p payload -> Printf.sprintf "%S" payload

let frame_to_string frame =
  Printf.sprintf "<Frame %s channel=%d size=%d payload=%s>"
    (frame_type_to_string frame.frame_type) frame.channel frame.size (frame_payload_to_string frame.payload)


let parse_method_args buf class_id method_id =
  try
    let (module P: Stubs.Method_instance) = Generated_methods.build_method_instance (class_id, method_id) buf in
    P.Method.list_of_t P.this
  with
  | Not_found -> Methods.parse_unknown_payload buf

let parse_method_payload buf =
  let class_id = consume_short buf in
  let method_id = consume_short buf in
  let arguments = parse_method_args buf class_id method_id in
  let unconsumed = Parse_buf.length buf in
  if unconsumed > 0
  then failwith (Printf.sprintf "Unconsumed payload buffer: %d" unconsumed);
  { class_id; method_id; arguments }

let consume_payload buf method_type =
  match method_type with
  | Method -> Method_p (parse_method_payload buf)
  | Header -> Header_p (consume_str buf @@ Parse_buf.length buf)
  | Body -> Body_p (consume_str buf @@ Parse_buf.length buf)
  | Heartbeat -> Heartbeat_p (consume_str buf @@ Parse_buf.length buf)


let byte_to_frame_type = function
  | 1 -> Method
  | 2 -> Header
  | 3 -> Body
  | 4 -> Heartbeat
  | _ -> assert false

let consume_frame_type buf =
  byte_to_frame_type @@ consume_byte buf


let consume_frame str =
  if String.length str < minimum_frame_length
  then (None, str)
  else
    let buf = Parse_buf.from_string str in
    let frame_type = consume_frame_type buf in
    let channel = consume_short buf in
    let size = consume_long buf in
    if Parse_buf.length buf <= size
    then (None, str)
    else
      let payload_buf = consume_buf buf size in
      let payload = consume_payload payload_buf frame_type in
      let frame_end = consume_byte buf in
      assert (frame_end = 0xCE);
      Some { frame_type; channel; size; payload }, Parse_buf.to_string buf
