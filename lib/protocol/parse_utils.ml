
module Parse_buf = struct
  type t = string ref

  let from_string = ref

  let to_string = (!)

  let copy buf  = ref !buf

  let length buf =
    String.length !buf

  let advance buf length =
    buf := String.sub !buf length ((String.length !buf) - length)

end



let consume_char buf =
  let value = !buf.[0] in
  Parse_buf.advance buf 1;
  value

let consume_byte buf =
  int_of_char @@ consume_char buf

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

let consume_str buf length =
  let value = String.sub !buf 0 length in
  Parse_buf.advance buf length;
  value

let consume_buf buf length =
  Parse_buf.from_string @@ consume_str buf length


let consume_int32 buf =
  let high = Int32.of_int @@ consume_short buf in
  let low = Int32.of_int @@ consume_short buf in
  Int32.add (Int32.shift_left high 16) low

let consume_int64 buf =
  let high = Int64.of_int32 @@ consume_int32 buf in
  let low = Int64.of_int32 @@ consume_int32 buf in
  Int64.add (Int64.shift_left high 32) low

let consume_float buf =
  Int32.float_of_bits @@ consume_int32 buf

let consume_double buf =
  Int64.float_of_bits @@ consume_int64 buf

let consume_short_str buf =
  let size = consume_byte buf in
  consume_str buf size

let consume_long_str buf =
  let size = consume_long buf in
  consume_str buf size
