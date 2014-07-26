

type frame_type =
  | Method
  | Header
  | Body
  | Heartbeat

type field_table = (string * field_value) list

and field_value =
  (* TODO: overflows? *)
  | (* t *) Boolean of bool
  | (* b *) Shortshort_int of int
  | (* B *) Shortshort_uint of int
  | (* U *) Short_int of int
  | (* u *) Short_uint of int
  | (* I *) Long_int of int
  | (* i *) Long_uint of int
  | (* L *) Longlong_int of int
  | (* l *) Longlong_uint of int
  | (* f *) Float of float
  | (* d *) Double of float
  (* | (\* D *\) Decimal of ??? *)
  | (* s *) Short_string of string
  | (* S *) Long_string of string
  (* | (\* A *\) Field_array of ??? *)
  | (* T *) Timestamp of int
  | (* F *) Field_table of field_table
  | (* V *) No_value

type amqp_field =
  (* TODO: overflows? *)
  | Octet of int
  | Short of int
  | Long of int
  | Longlong of int
  | Bit of bool
  | Shortstring of string
  | Longstring of string
  | Timestamp of int
  | Table of field_table
  | Unparsed of string (* TODO: Kill this when we parse all payloads. *)

type method_payload = {
  class_id : int;
  method_id : int;
  arguments : (string * amqp_field) list; (* TODO: Determine if this is what we want. *)
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


(* amqp_field parsers *)

let consume_octet buf =
  Octet (consume_byte buf)

let _consume_short_str buf =
  let size = consume_byte buf in
  consume_str buf size

let consume_short_str buf =
  Shortstring (_consume_short_str buf)

let _consume_long_str buf =
  let size = consume_long buf in
  consume_str buf size

let consume_long_str buf =
  Longstring (_consume_long_str buf)

let rec consume_table_entry buf =
  let name = _consume_short_str buf in
  let field = match consume_char buf with
    | 't' -> Boolean (consume_byte buf = 0)
    | 'b' -> Shortshort_int (consume_byte buf)
    | 'B' -> Shortshort_uint (consume_byte buf)
    | 'U' -> Short_int (consume_short buf)
    | 'u' -> Short_uint (consume_short buf)
    | 'I' -> Long_int (consume_long buf)
    | 'i' -> Long_uint (consume_long buf)
    | 'L' -> Longlong_int (consume_long_long buf)
    | 'l' -> Longlong_uint (consume_long_long buf)
    | 'f' -> Float (consume_float buf)
    | 'd' -> Double (consume_double buf)
    (* | 'D' -> Decimal (???) *)
    | 's' -> Short_string (_consume_short_str buf)
    | 'S' -> Long_string (_consume_long_str buf)
    (* | 'A' -> Field_array (???) *)
    | 'T' -> Timestamp (consume_long_long buf)
    | 'F' -> Field_table (consume_table buf)
    | 'V' -> No_value
    | field_type -> failwith @@ Printf.sprintf "Unknown field type %C" field_type
  in
  name, field

and consume_table_entries buf =
  if Parse_buf.length buf = 0
  then []
  else let table_entry = consume_table_entry buf in
    table_entry :: consume_table_entries buf

and consume_table buf =
  let size = Parse_utils.consume_long buf in
  let table_buf = Parse_utils.consume_buf buf size in
  let table = consume_table_entries table_buf in
  assert (Parse_buf.length table_buf = 0);
  table

let consume_amqp_table buf =
  Table (consume_table buf)

(* TODO: Autogenerate some of these *)

let parse_args_connection_start buf =
  let version_major = consume_octet buf in
  let version_minor = consume_octet buf in
  let server_properties = consume_amqp_table buf in
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
