
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
  type field =
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
    | (* F *) Field_table of table
    | (* V *) No_value
  and table = (string * field) list

  let rec consume_table_entry buf =
    let name = Parse_utils.consume_short_str buf in
    let table_field = match Parse_utils.consume_char buf with
      | 't' -> Boolean (Parse_utils.consume_byte buf = 0)
      | 'b' -> Shortshort_int (Parse_utils.consume_byte buf)
      | 'B' -> Shortshort_uint (Parse_utils.consume_byte buf)
      | 'U' -> Short_int (Parse_utils.consume_short buf)
      | 'u' -> Short_uint (Parse_utils.consume_short buf)
      | 'I' -> Long_int (Parse_utils.consume_long buf)
      | 'i' -> Long_uint (Parse_utils.consume_long buf)
      | 'L' -> Longlong_int (Parse_utils.consume_long_long buf)
      | 'l' -> Longlong_uint (Parse_utils.consume_long_long buf)
      | 'f' -> Float (Parse_utils.consume_float buf)
      | 'd' -> Double (Parse_utils.consume_double buf)
      (* | 'D' -> Decimal (???) *)
      | 's' -> Short_string (Parse_utils.consume_short_str buf)
      | 'S' -> Long_string (Parse_utils.consume_long_str buf)
      (* | 'A' -> Field_array (???) *)
      | 'T' -> Timestamp (Parse_utils.consume_long_long buf)
      | 'F' -> Field_table (consume_table buf)
      | 'V' -> No_value
      | field_type -> failwith (Printf.sprintf "Unknown field type %C" field_type)
    in
    name, table_field

  and consume_table_entries buf =
    if Parse_utils.Parse_buf.length buf = 0
    then []
    else let table_entry = consume_table_entry buf in
      table_entry :: consume_table_entries buf

  and consume_table buf =
    let size = Parse_utils.consume_long buf in
    let table_buf = Parse_utils.consume_buf buf size in
    let table = consume_table_entries table_buf in
    assert (Parse_utils.Parse_buf.length table_buf = 0);
    table

  let rec emit_table_entry (name, value) =
    let field_type, field_value = match value with
      | Boolean value -> 't', if value then "\000" else "\001"
      | Shortshort_int value -> 'b', Parse_utils.emit_octet value
      | Shortshort_uint value -> 'B', Parse_utils.emit_octet value
      | Short_int value -> 'U', Parse_utils.emit_short value
      | Short_uint value -> 'u', Parse_utils.emit_short value
      | Long_int value -> 'I', Parse_utils.emit_long value
      | Long_uint value -> 'i', Parse_utils.emit_long value
      | Longlong_int value -> 'L', Parse_utils.emit_long_long value
      | Longlong_uint value -> 'l', Parse_utils.emit_long_long value
      | Float value -> 'f', Parse_utils.emit_float value
      | Double value -> 'd', Parse_utils.emit_double value
      (* | Decimal value -> 'D', ??? *)
      | Short_string value -> 's', Parse_utils.emit_short_str value
      | Long_string value -> 'S', Parse_utils.emit_long_str value
      (* | Field_array value -> 'A', ??? *)
      | Timestamp value -> 'T', Parse_utils.emit_long_long value
      | Field_table value -> 'F', emit_table value
      | No_value -> 'V', ""
    in
    Printf.sprintf "%s%c%s" (Parse_utils.emit_short_str name) field_type field_value

  and emit_table_entries value =
    String.concat "" (List.map emit_table_entry value)

  and emit_table value =
    let table_entries = emit_table_entries value in
    (Parse_utils.emit_long (String.length table_entries)) ^ table_entries

end

module Amqp_field = struct

  type t =
    (* TODO: overflows? *)
    | Octet of int
    | Short of int
    | Long of int
    | Longlong of int
    | Bit of bool
    | Shortstring of string
    | Longstring of string
    | Timestamp of int
    | Table of Amqp_table.table

  (* amqp_field parsers *)

  let consume_field buf = function
    | Field_type.Octet       -> Octet (Parse_utils.consume_byte buf)
    | Field_type.Short       -> Short (Parse_utils.consume_short buf)
    | Field_type.Long        -> Long (Parse_utils.consume_long buf)
    | Field_type.Longlong    -> Longlong (Parse_utils.consume_long_long buf)
    | Field_type.Bit         -> failwith "I don't know how to parse Bit fields yet, sorry."
    | Field_type.Shortstring -> Shortstring (Parse_utils.consume_short_str buf)
    | Field_type.Longstring  -> Longstring (Parse_utils.consume_long_str buf)
    | Field_type.Timestamp   -> Timestamp (Parse_utils.consume_long_long buf)
    | Field_type.Table       -> Table (Amqp_table.consume_table buf)

  let emit_field = function
    | (_ : string), Octet value -> Parse_utils.emit_octet value
    | (_ : string), Short value -> Parse_utils.emit_short value
    | (_ : string), Long value -> Parse_utils.emit_long value
    | (_ : string), Longlong value -> Parse_utils.emit_long_long value
    | (_ : string), Bit value -> failwith "I don't know how to emit Bit fields yet, sorry."
    | (_ : string), Shortstring value -> Parse_utils.emit_short_str value
    | (_ : string), Longstring value -> Parse_utils.emit_long_str value
    | (_ : string), Timestamp value -> Parse_utils.emit_long_long value
    | (_ : string), Table value -> Amqp_table.emit_table value

end


(*****************************************************************************)


module Method_utils = struct
  let buf_to_list arguments buf =
    let consume_argument (name, field_type) =
      name, Amqp_field.consume_field buf field_type
    in
    List.map consume_argument arguments

  let string_of_list class_id method_id payload =
    let field_strings = List.map Amqp_field.emit_field payload in
    let payload_strings = (Parse_utils.emit_short class_id) :: (Parse_utils.emit_short method_id) :: field_strings in
    String.concat "" payload_strings
end
