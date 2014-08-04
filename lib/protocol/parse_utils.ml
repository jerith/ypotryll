
module Parse_buf = struct
  type t = {
    mutable str : string;
    mutable bits : int;
  }

  let from_string str =
    { str; bits = 0 }

  let to_string buf =
    buf.str

  let length buf =
    String.length buf.str

  let advance buf length =
    let str = String.sub buf.str length ((String.length buf.str) - length) in
    buf.str <- str;
    buf.bits <- 0

  let clear_bits buf =
    if buf.bits > 0
    then advance buf 1

  let consume_char buf =
    clear_bits buf;
    let value = buf.str.[0] in
    advance buf 1;
    value

  let consume_str buf length =
    clear_bits buf;
    let value = String.sub buf.str 0 length in
    advance buf length;
    value

  let consume_bit buf =
    if buf.bits > 7 then clear_bits buf;
    let value = (int_of_char buf.str.[0]) land (1 lsl buf.bits) in
    buf.bits <- buf.bits + 1;
    value <> 0

end


module Build_buf = struct
  (* Pretty much the same as Parse_buf, but for building. *)

  type t = {
    mutable str : string;
    mutable bits : int;
  }

  let from_string str =
    { str; bits = 0 }

  let to_string buf =
    buf.str

  let length buf =
    String.length buf.str

  let clear_bits buf =
    buf.bits <- 0

  let add_str buf str =
    clear_bits buf;
    buf.str <- buf.str ^ str

  let add_char buf char =
    add_str buf (String.make 1 char)

  let add_bit buf bit =
    if buf.bits > 7 then clear_bits buf;
    if buf.bits = 0 then add_char buf '\000';
    if bit then begin
      let pos = length buf - 1 in
      let value = (1 lsl buf.bits) lor int_of_char buf.str.[pos] in
      buf.str.[pos] <- char_of_int value
    end;
    buf.bits <- buf.bits + 1

end


let consume_char = Parse_buf.consume_char

let consume_str = Parse_buf.consume_str

let consume_bit = Parse_buf.consume_bit

let consume_buf buf length =
  Parse_buf.from_string (consume_str buf length)


let consume_byte buf =
  int_of_char (consume_char buf)

let consume_short buf =
  let high = consume_byte buf in
  let low = consume_byte buf in
  (high lsl 8) + low

let consume_long buf =
  (* TODO: Figure out how to handle potential overflows. *)
  let high = consume_short buf in
  let low = consume_short buf in
  (high lsl 16) + low

let consume_long_long buf =
  (* TODO: Figure out how to handle potential overflows. *)
  let high = consume_long buf in
  let low = consume_long buf in
  (high lsl 32) + low


let consume_int32 buf =
  let high = Int32.of_int (consume_short buf) in
  let low = Int32.of_int (consume_short buf) in
  Int32.add (Int32.shift_left high 16) low

let consume_int64 buf =
  let high = Int64.of_int32 (consume_int32 buf) in
  let low = Int64.of_int32 (consume_int32 buf) in
  Int64.add (Int64.shift_left high 32) low

let consume_float buf =
  Int32.float_of_bits (consume_int32 buf)

let consume_double buf =
  Int64.float_of_bits (consume_int64 buf)

let consume_short_str buf =
  let size = consume_byte buf in
  consume_str buf size

let consume_long_str buf =
  let size = consume_long buf in
  consume_str buf size


let add_char = Build_buf.add_char

let add_str = Build_buf.add_str

let add_bit = Build_buf.add_bit

let add_octet buf value =
  Build_buf.add_char buf (char_of_int value)

let add_short buf value =
  add_octet buf (value lsr 8);
  add_octet buf (value land 0xff)

let add_long buf value =
  add_short buf (value lsr 16);
  add_short buf (value land 0xffff)

let add_long_long buf value =
  add_long buf (value lsr 32);
  add_long buf (value land 0xffffffff)

let add_int32 buf value =
  let high = Int32.(to_int (shift_right value 16)) in
  let low = Int32.(to_int (logand value (of_int 0xFFFF))) in
  add_short buf high;
  add_short buf low

let add_int64 buf value =
  let high = Int64.(to_int32 (shift_right value 32)) in
  let low = Int64.(to_int32 (logand value (of_int 0xFFFFFFFF))) in
  add_int32 buf high;
  add_int32 buf low

let add_float buf value =
  add_int32 buf (Int32.bits_of_float value)

let add_double buf value =
  add_int64 buf (Int64.bits_of_float value)

let add_short_str buf value =
  add_octet buf (String.length value);
  Build_buf.add_str buf value

let add_long_str buf value =
  add_long buf (String.length value);
  Build_buf.add_str buf value
