
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

module Amqp_field = struct
  type table_field =
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
  and table = (string * table_field) list

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
    | Table of table
    | Unparsed of string (* TODO: Kill this when we parse all payloads. *)

  (* amqp_field parsers *)

  let _consume_short_str buf =
    let size = Parse_utils.consume_byte buf in
    Parse_utils.consume_str buf size

  let _consume_long_str buf =
    let size = Parse_utils.consume_long buf in
    Parse_utils.consume_str buf size

  let rec consume_table_entry buf =
    let name = _consume_short_str buf in
    let field = match Parse_utils.consume_char buf with
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
      | 's' -> Short_string (_consume_short_str buf)
      | 'S' -> Long_string (_consume_long_str buf)
      (* | 'A' -> Field_array (???) *)
      | 'T' -> Timestamp (Parse_utils.consume_long_long buf)
      | 'F' -> Field_table (consume_table buf)
      | 'V' -> No_value
      | field_type -> failwith @@ Printf.sprintf "Unknown field type %C" field_type
    in
    name, field

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

  let consume_field buf = function
      | Field_type.Octet       -> Octet (Parse_utils.consume_byte buf)
      | Field_type.Short       -> Short (Parse_utils.consume_short buf)
      | Field_type.Long        -> Long (Parse_utils.consume_long buf)
      | Field_type.Longlong    -> Longlong (Parse_utils.consume_long_long buf)
      | Field_type.Bit         -> failwith "I don't know how to parse Bit fields yet, sorry."
      | Field_type.Shortstring -> Shortstring (_consume_short_str buf)
      | Field_type.Longstring  -> Longstring (_consume_long_str buf)
      | Field_type.Timestamp   -> Timestamp (Parse_utils.consume_long_long buf)
      | Field_type.Table       -> Table (consume_table buf)

end




module type Amqp_method_payload_definition = sig
  val class_id : int
  val method_id : int
  val arguments : (string * Field_type.t) list

  type t

  val t_to_list : t -> (string * Amqp_field.t) list
  val t_from_list : (string * Amqp_field.t) list -> t
end


module type Amqp_method_payload = sig
  val class_id : int
  val method_id : int

  type t

  val parse_method : Parse_utils.Parse_buf.t -> t
  val build_method : t -> string

  (* temporary *)
  val buf_to_list : Parse_utils.Parse_buf.t -> (string * Amqp_field.t) list
  val string_of_list : (string * Amqp_field.t) list -> string
end


module Make_method_payload (M : Amqp_method_payload_definition) : Amqp_method_payload = struct
  let class_id = M.class_id
  let method_id = M.method_id
  let _arguments = M.arguments

  type t = M.t

  let buf_to_list buf =
    let parse_field (name, field_type) =
      name, Amqp_field.consume_field buf field_type
    in
    List.map parse_field _arguments

  let string_of_list fields =
    ""

  let parse_method buf =
    M.t_from_list @@ buf_to_list buf

  let build_method payload =
    string_of_list @@ M.t_to_list payload
end
