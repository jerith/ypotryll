
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
      | field_type -> failwith (Printf.sprintf "Unknown field type %C" field_type)
    in
    name, table_field

  and consume_table_entries buf =
    if PU.Parse_buf.length buf = 0
    then []
    else let table_entry = consume_table_entry buf in
      table_entry :: consume_table_entries buf

  and consume_table buf =
    let size = PU.consume_long buf in
    let table_buf = PU.consume_buf buf size in
    let table = consume_table_entries table_buf in
    assert (PU.Parse_buf.length table_buf = 0);
    table

  let rec add_table_entry buf (name, value) =
    PU.add_short_str buf name;
    match value with
    | Boolean value -> PU.add_char buf 't'; PU.add_octet buf (if value then 1 else 0)
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
end
