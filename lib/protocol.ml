
module PU = Parse_utils

module Field_type = struct
  type t =
    | Octet
    | Short
    | Long
    | Longlong
    | Bit
    | Shortstring
    | Longstring
    | Timestamp
    | Table
end

module Amqp_table = struct
  open Ypotryll_field_types.Table

  let rec consume_table_entry buf =
    let name = PU.consume_short_str buf in
    let table_field = match PU.consume_char buf with
      | 't' -> Boolean (PU.consume_byte buf = 0)
      | 'b' -> Shortshort_int (PU.consume_byte buf)
      | 'B' -> Shortshort_uint (PU.consume_byte buf)
      | 'U' -> Short_int (PU.consume_short buf)
      | 'u' -> Short_uint (PU.consume_short buf)
      | 'I' -> Long_int (PU.consume_long buf)
      | 'i' -> Long_uint (PU.consume_long buf)
      | 'L' -> Longlong_int (PU.consume_long_long buf)
      | 'l' -> Longlong_uint (PU.consume_long_long buf)
      | 'f' -> Float (PU.consume_float buf)
      | 'd' -> Double (PU.consume_double buf)
      (* | 'D' -> Decimal (???) *)
      | 's' -> Short_string (PU.consume_short_str buf)
      | 'S' -> Long_string (PU.consume_long_str buf)
      (* | 'A' -> Field_array (???) *)
      | 'T' -> Timestamp (PU.consume_long_long buf)
      | 'F' -> Field_table (consume_table buf)
      | 'V' -> No_value
      | field_type ->
        failwith (Printf.sprintf "Unknown field type %C" field_type)
    in
    name, table_field

  and consume_table_entries buf =
    match PU.Parse_buf.length buf with
    | 0 -> []
    | _ ->
      let table_entry = consume_table_entry buf in
      table_entry :: consume_table_entries buf

  and consume_table buf =
    let size = PU.consume_size buf in
    let table_buf = PU.consume_buf buf size in
    let table = consume_table_entries table_buf in
    assert (PU.Parse_buf.length table_buf = 0);
    table

  let rec add_table_entry buf (name, value) =
    PU.add_short_str buf name;
    let int_bool = function true -> 1 | false -> 0 in
    match value with
    | Boolean value -> PU.add_char buf 't'; PU.add_octet buf (int_bool value)
    | Shortshort_int value -> PU.add_char buf 'b'; PU.add_octet buf value
    | Shortshort_uint value -> PU.add_char buf 'B'; PU.add_octet buf value
    | Short_int value -> PU.add_char buf 'U'; PU.add_short buf value
    | Short_uint value -> PU.add_char buf 'u'; PU.add_short buf value
    | Long_int value -> PU.add_char buf 'I'; PU.add_long buf value
    | Long_uint value -> PU.add_char buf 'i'; PU.add_long buf value
    | Longlong_int value -> PU.add_char buf 'L'; PU.add_long_long buf value
    | Longlong_uint value -> PU.add_char buf 'l'; PU.add_long_long buf value
    | Float value -> PU.add_char buf 'f'; PU.add_float buf value
    | Double value -> PU.add_char buf 'd'; PU.add_double buf value
    (* | Decimal value -> PU.add_char buf 'D'; ??? *)
    | Short_string value -> PU.add_char buf 's'; PU.add_short_str buf value
    | Long_string value -> PU.add_char buf 'S'; PU.add_long_str buf value
    (* | Field_array value -> PU.add_char buf 'A'; ??? *)
    | Timestamp value -> PU.add_char buf 'T'; PU.add_long_long buf value
    | Field_table value -> PU.add_char buf 'F'; add_table buf value
    | No_value -> PU.add_char buf 'V'

  and add_table_entries buf value =
    List.iter (add_table_entry buf) value

  and add_table buf value =
    let table_buf = PU.Build_buf.from_string "" in
    add_table_entries table_buf value;
    PU.add_long_str buf (PU.Build_buf.to_string table_buf)

  let rec dump_field_table field_table =
    "{" ^ (String.concat "; " (List.map dump_field_entry field_table)) ^ "}"

  and dump_field_entry (name, field_value) =
    match field_value with
    | Boolean value -> Printf.sprintf "<Boolean %s=%b>" name value
    | Shortshort_int value -> Printf.sprintf "<Shortshort_int %s=%d>" name value
    | Shortshort_uint value ->
      Printf.sprintf "<Shortshort_uint %s=%u>" name value
    | Short_int value -> Printf.sprintf "<Short_int %s=%d>" name value
    | Short_uint value -> Printf.sprintf "<Short_uint %s=%u>" name value
    | Long_int value -> Printf.sprintf "<Long_int %s=%ld>" name value
    | Long_uint value -> Printf.sprintf "<Long_uint %s=%lu>" name value
    | Longlong_int value -> Printf.sprintf "<Longlong_int %s=%Ld>" name value
    | Longlong_uint value -> Printf.sprintf "<Longlong_uint %s=%Lu>" name value
    | Float value -> Printf.sprintf "<Float %s=%f>" name value
    | Double value -> Printf.sprintf "<Double %s=%f>" name value
    (* | Decimal value -> "???" *)
    | Short_string value -> Printf.sprintf "<Short_string %s=%S>" name value
    | Long_string value -> Printf.sprintf "<Long_string %s=%S>" name value
    (* | Field_array value -> "???" *)
    | Timestamp value -> Printf.sprintf "<Timestamp %s=%Lu>" name value
    | Field_table value ->
      Printf.sprintf "<Field_table %s=%s>" name (dump_field_table value)
    | No_value -> Printf.sprintf "<No_value %s>" name

end

module Amqp_field = struct

  type t =
    | Octet of int
    | Short of int
    | Long of int32
    | Longlong of int64
    | Bit of bool
    | Shortstring of string
    | Longstring of string
    | Timestamp of int64
    | Table of Ypotryll_field_types.Table.t

  (* amqp_field parsers *)

  let consume_field buf = function
    | Field_type.Octet       -> Octet (PU.consume_byte buf)
    | Field_type.Short       -> Short (PU.consume_short buf)
    | Field_type.Long        -> Long (PU.consume_long buf)
    | Field_type.Longlong    -> Longlong (PU.consume_long_long buf)
    | Field_type.Bit         -> Bit (PU.consume_bit buf)
    | Field_type.Shortstring -> Shortstring (PU.consume_short_str buf)
    | Field_type.Longstring  -> Longstring (PU.consume_long_str buf)
    | Field_type.Timestamp   -> Timestamp (PU.consume_long_long buf)
    | Field_type.Table       -> Table (Amqp_table.consume_table buf)

  let add_field buf = function
    | (_ : string), Octet value -> PU.add_octet buf value
    | (_ : string), Short value -> PU.add_short buf value
    | (_ : string), Long value -> PU.add_long buf value
    | (_ : string), Longlong value -> PU.add_long_long buf value
    | (_ : string), Bit value -> PU.add_bit buf value
    | (_ : string), Shortstring value -> PU.add_short_str buf value
    | (_ : string), Longstring value -> PU.add_long_str buf value
    | (_ : string), Timestamp value -> PU.add_long_long buf value
    | (_ : string), Table value -> Amqp_table.add_table buf value

  let dump_field (name, field) =
    match field with
    | Octet value       -> Printf.sprintf "<Octet %s %u>" name value
    | Short value       -> Printf.sprintf "<Short %s %u>" name value
    | Long value        -> Printf.sprintf "<Long %s %lu>" name value
    | Longlong value    -> Printf.sprintf "<LongLong %s %Lu>" name value
    | Bit value         -> Printf.sprintf "<Bit %s %b>" name value
    | Shortstring value -> Printf.sprintf "<Shortstring %s %S>" name value
    | Longstring value  -> Printf.sprintf "<Longstring %s %S>" name value
    | Timestamp value   -> Printf.sprintf "<Timestamp %s %Lu>" name value
    | Table value       -> Printf.sprintf "<Table %s %s>"
                             name (Amqp_table.dump_field_table value)

end


(*****************************************************************************)


module Method_utils = struct
  let buf_to_list arguments buf =
    let consume_argument (name, field_type) =
      name, Amqp_field.consume_field buf field_type
    in
    List.map consume_argument arguments

  let string_of_list class_id method_id payload =
    let buf = PU.Build_buf.from_string "" in
    PU.add_short buf class_id;
    PU.add_short buf method_id;
    List.iter (Amqp_field.add_field buf) payload;
    PU.Build_buf.to_string buf

  let dump_list name class_id method_id payload =
    let args = String.concat "; " (List.map Amqp_field.dump_field payload) in
    Printf.sprintf "<Method %s (%d, %d) [%s]>" name class_id method_id args
end


module Header_utils = struct

  type property = string * Amqp_field.t option

  let rec _parse_property_flags collected_props properties buf =
    let flags = PU.consume_short buf in
    let rec parse_bits collected_props i properties =
      match i, flags land (1 lsl i) <> 0, properties with
      | 0, false, [] -> List.rev collected_props
      | 0, false, _ :: _ ->
        failwith "End of property flags, but not properties."
      | 0, true, [] -> failwith "End of properties, but not property flags."
      | 0, true, props -> _parse_property_flags collected_props props buf
      | i, flag, [] -> parse_bits collected_props (i - 1) []
      | i, flag, prop :: props ->
        parse_bits ((flag, prop) :: collected_props) (i -1) props
    in
    parse_bits collected_props 15 properties

  let parse_properties properties buf =
    let flagged_properties = _parse_property_flags [] properties buf in
    let consume_property (flag, (name, field_type)) =
      match field_type with
      | Field_type.Bit -> (name, Some (Amqp_field.Bit flag))
      | _ ->
        match flag with
        | true -> (name, Some (Amqp_field.consume_field buf field_type))
        | false -> (name, None)
    in
    List.map consume_property flagged_properties

  let rec _build_property_flags buf flags bit props =
    match bit, props with
    | _, [] -> PU.add_short buf flags
    | 0, props ->
      PU.add_short buf (flags lor 1); _build_property_flags buf 0 15 props
    | i, (_, None) :: props -> _build_property_flags buf flags (i - 1) props
    | i, (_, Some (Amqp_field.Bit false)) :: props ->
      _build_property_flags buf flags (i - 1) props
    | i, (_, Some _) :: props ->
      _build_property_flags buf (flags lor (1 lsl bit)) (i - 1) props

  let build_properties payload =
    let buf = PU.Build_buf.from_string "" in
    _build_property_flags buf 0 15 payload;
    let add_property = function
      | (_ : string), None -> ()
      | (_ : string), Some (Amqp_field.Bit _) -> ()
      | (name : string), Some field -> Amqp_field.add_field buf (name, field)
    in
    List.iter add_property payload;
    PU.Build_buf.to_string buf

  let dump_list name class_id method_id payload =
    let args = String.concat "; " (List.map Amqp_field.dump_field payload) in
    Printf.sprintf "<Method %s (%d, %d) [%s]>" name class_id method_id args
end
