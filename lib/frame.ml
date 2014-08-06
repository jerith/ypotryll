
module FC = Generated_frame_constants
module MTypes = Generated_method_types


type payload =
  | Method of MTypes.method_payload
  | Header of string
  | Body of string
  | Heartbeat


type t = int * payload

let minimum_frame_length = 8


open Parse_utils

(* String formatting *)

let frame_type_to_string = function
  | FC.Method_frame    -> "Method"
  | FC.Header_frame    -> "Header"
  | FC.Body_frame      -> "Body"
  | FC.Heartbeat_frame -> "Heartbeat"

let rec field_table_to_string field_table =
  "{" ^ (String.concat "; " (List.map field_entry_to_string field_table)) ^ "}"

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

let method_args_to_string payload =
  let (module P : Generated_methods.Method) = Generated_methods.module_for payload in
  let args = P.list_of_t payload in
  let args_str = String.concat "; " (List.map amqp_field_to_string args) in
  Printf.sprintf "<Method (%d, %d) [%s]>" P.class_id P.method_id args_str

let frame_to_string = function
  | channel, Method payload ->
    Printf.sprintf "<Method ch=%d %s>" channel (method_args_to_string payload)
  | channel, Header payload ->
    Printf.sprintf "<Header ch=%d %S>" channel payload
  | channel, Body payload ->
    Printf.sprintf "<Body ch=%d %S>" channel payload
  | channel, Heartbeat ->
    Printf.sprintf "<Heartbeat ch=%d>" channel


let parse_method_args buf class_id method_id =
  try
    Generated_methods.build_method_instance (class_id, method_id) buf
  with
  | Not_found -> failwith (
      Printf.sprintf "Unknown method (%d, %d) with payload: %S"
        class_id method_id (Parse_utils.consume_str buf (Parse_utils.Parse_buf.length buf)))

let parse_method_payload buf =
  let class_id = consume_short buf in
  let method_id = consume_short buf in
  parse_method_args buf class_id method_id


let consume_frame_type buf =
  Generated_frame_constants.byte_to_frame_type (consume_byte buf)


let consume_payload_str buf =
  consume_str buf (Parse_buf.length buf)


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
    else begin
      let payload_buf = consume_buf buf size in
      let frame = match frame_type with
        | FC.Method_frame -> (channel, Method (parse_method_payload payload_buf))
        | FC.Header_frame -> (channel, Header (consume_payload_str payload_buf))
        | FC.Body_frame -> (channel, Body (consume_payload_str payload_buf))
        | FC.Heartbeat_frame -> (channel, Heartbeat)
      in
      let unconsumed = Parse_buf.length payload_buf in
      if unconsumed > 0
      then failwith (Printf.sprintf "Unconsumed payload buffer: %d" unconsumed);
      assert (consume_byte buf = FC.frame_end);
      (Some frame, Parse_buf.to_string buf)
    end


let make_method channel method_payload =
  (channel, Method method_payload)


let build_method_payload payload =
  let (module P : Generated_methods.Method) = Generated_methods.module_for payload in
  P.build_method payload


let build_frame (channel, payload) =
  let buf = Build_buf.from_string "" in
  let frame_type, payload_str = match payload with
    | Method payload -> FC.Method_frame, build_method_payload payload
    | Header payload -> FC.Header_frame, payload
    | Body payload -> FC.Body_frame, payload
    | Heartbeat -> FC.Heartbeat_frame, ""
  in
  add_str buf (FC.emit_frame_type frame_type);
  add_short buf channel;
  add_long_str buf payload_str;
  add_octet buf FC.frame_end;
  Build_buf.to_string buf
