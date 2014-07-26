
type frame_type =
  | Method
  | Header
  | Body
  | Heartbeat

type data_field =
  (* TODO: overflows? *)
  | Octet of int
  | Short of int
  | Long of int
  | Longlong of int
  | Bit of bool
  | Shortstring of string
  | Longstring of string
  | Timestamp of int
  | Table of string (* placeholder *)
  | Unparsed of string (* TODO: Kill this when we parse all payloads. *)

type method_payload = {
  class_id : int;
  method_id : int;
  arguments : (string * data_field) list; (* TODO: Determine if this is what we want. *)
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
  (* payload : string; *)
  payload : frame_payload;
}

let minimum_frame_length = 8


open Parse_utils


(* data_field parsers *)

let consume_octet buf =
  Octet (Parse_utils.consume_byte buf)

let consume_long_str buf =
  let size = Parse_utils.consume_long buf in
  Longstring (Parse_utils.consume_str buf size)

let consume_table buf =
  let size = Parse_utils.consume_long buf in
  Longstring (Parse_utils.consume_str buf size)

(* TODO: Autogenerate some of these *)

let parse_args_connection_start buf =
  let version_major = consume_octet buf in
  let version_minor = consume_octet buf in
  let server_properties = consume_table buf in
  let mechanisms = consume_long_str buf in
  let locales = consume_long_str buf in
  [
    "version-major", version_major;
    "version-minor", version_minor;
    "server-properties", server_properties;
    "mechanisms", mechanisms;
    "locales", locales;
  ]

(* END Autogenerate *)

let parse_method_args buf class_id method_id =
  match class_id, method_id with
  | 10, 10 -> parse_args_connection_start buf
  | _ -> [ ("unparsed", Unparsed (consume_str buf @@ Parse_buf.length buf)) ]

let parse_method_payload buf =
  let class_id = consume_short buf in
  let method_id = consume_short buf in
  let arguments = parse_method_args buf class_id method_id in
  assert (Parse_buf.length buf = 0);
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


(* String formatting *)

let frame_type_to_string = function
  | Method    -> "Method"
  | Header    -> "Header"
  | Body      -> "Body"
  | Heartbeat -> "Heartbeat"

let data_field_to_string (name, field) =
  match field with
  | Octet value       -> Printf.sprintf "<Octet %s %d>" name value
  | Short value       -> Printf.sprintf "<Short %s %d>" name value
  | Long value        -> Printf.sprintf "<Long %s %d>" name value
  | Longlong value    -> Printf.sprintf "<LongLong %s %d>" name value
  | Bit value         -> Printf.sprintf "<Bit %s %b>" name value
  | Shortstring value -> Printf.sprintf "<Shortstring %s %S>" name value
  | Longstring value  -> Printf.sprintf "<Longstring %s %S>" name value
  | Timestamp value   -> Printf.sprintf "<Timestamp %s %d>" name value
  | Table value       -> Printf.sprintf "<Table %s %S>" name value (* placeholder *)
  | Unparsed value    -> Printf.sprintf "<Unparsed %s %S>" name value (* TODO: Kill this when we parse all payloads. *)

let method_args_to_string args =
  Printf.sprintf "[%s]" @@ String.concat "; " (List.map data_field_to_string args)

let frame_payload_to_string = function
  | Method_p payload -> Printf.sprintf "<class=%d method=%d %s>"
                          payload.class_id payload.method_id (method_args_to_string payload.arguments)
  | Header_p payload -> Printf.sprintf "%S" payload
  | Body_p payload -> Printf.sprintf "%S" payload
  | Heartbeat_p payload -> Printf.sprintf "%S" payload

let frame_to_string frame =
  Printf.sprintf "<Frame %s channel=%d size=%d payload=%s>"
    (frame_type_to_string frame.frame_type) frame.channel frame.size (frame_payload_to_string frame.payload)

