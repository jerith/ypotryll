
module Parse_buf : sig
  type t

  val from_string : string -> t
  val to_string : t -> string
  val copy : t -> t
  val length : t -> int
end

val consume_char : Parse_buf.t -> char

val consume_byte : Parse_buf.t -> int

val consume_short : Parse_buf.t -> int

val consume_long : Parse_buf.t -> int

val consume_long_long : Parse_buf.t -> int

val consume_str : Parse_buf.t -> int -> string

val consume_buf : Parse_buf.t -> int -> Parse_buf.t

val consume_float : Parse_buf.t -> float

val consume_double : Parse_buf.t -> float
