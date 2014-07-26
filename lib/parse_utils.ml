
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



let consume_byte buf =
  let value = int_of_char !buf.[0] in
  Parse_buf.advance buf 1;
  value

let consume_short buf =
  let high = consume_byte buf in
  let low = consume_byte buf in
  (high lsl 8) + low

let consume_long buf =
  (* TODO: Figure out how to handle potential overflows. *)
  let high = consume_short buf in
  let low = consume_short buf in
  (high lsl 16) + low

let consume_str buf length =
  let value = String.sub !buf 0 length in
  Parse_buf.advance buf length;
  value

let consume_buf buf length =
  Parse_buf.from_string @@ consume_str buf length
