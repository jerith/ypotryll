open OUnit2

open Parse_utils


let pr_buf buf =
  Printf.sprintf "{ str = %S; bits = %d }" buf.Parse_buf.str buf.Parse_buf.bits


let mk_buf str bits =
  { Parse_buf.str; Parse_buf.bits }


let assert_bufs_equal = assert_equal ~printer:pr_buf

let assert_strings_equal = assert_equal ~printer:(Printf.sprintf "%S")

let assert_ints_equal = assert_equal ~printer:(Printf.sprintf "%d")

let assert_chars_equal = assert_equal ~printer:(Printf.sprintf "'%c'")

let assert_bools_equal = assert_equal ~printer:(Printf.sprintf "%B")

let assert_all assertion values =
  List.iter (fun (expected, real) -> assertion expected real) values


let parse_buf_tests =
  "test_parse_buf" >::: [

    "test_from_string" >:: (fun ctx ->
        assert_all assert_bufs_equal [
          (mk_buf "foo" 0), (Parse_buf.from_string "foo");
          (mk_buf "barge" 0), (Parse_buf.from_string "barge");
        ]
      );

    "test_to_string" >:: (fun ctx ->
        assert_strings_equal "foo" (Parse_buf.to_string (mk_buf "foo" 0));
        assert_strings_equal "foo" (Parse_buf.to_string (mk_buf "foo" 1));
        assert_strings_equal "barge" (Parse_buf.to_string (mk_buf "barge" 0))
      );

    "test_length" >:: (fun ctx ->
        assert_ints_equal 3 (Parse_buf.length (mk_buf "foo" 0));
        assert_ints_equal 3 (Parse_buf.length (mk_buf "foo" 1));
        assert_ints_equal 5 (Parse_buf.length (mk_buf "barge" 0))
      );

    "test_advance" >:: (fun ctx ->
        let buf = mk_buf "12345" 0 in
        Parse_buf.advance buf 0; assert_bufs_equal (mk_buf "12345" 0) buf;
        Parse_buf.advance buf 1; assert_bufs_equal (mk_buf "2345" 0) buf;
        Parse_buf.advance buf 1; assert_bufs_equal (mk_buf "345" 0) buf;
        Parse_buf.advance buf 2; assert_bufs_equal (mk_buf "5" 0) buf
      );

    "test_advance_with_bits" >:: (fun ctx ->
        let buf = mk_buf "12345" 1 in
        Parse_buf.advance buf 1; assert_bufs_equal (mk_buf "2345" 0) buf
      );

    "test_clear_bits" >:: (fun ctx ->
        let buf = mk_buf "12345" 0 in
        Parse_buf.clear_bits buf; assert_bufs_equal (mk_buf "12345" 0) buf;
        let buf = mk_buf "12345" 1 in
        Parse_buf.clear_bits buf; assert_bufs_equal (mk_buf "2345" 0) buf
      );

    "test_consume_char" >:: (fun ctx ->
        let buf = mk_buf "12345" 0 in
        assert_chars_equal '1' (Parse_buf.consume_char buf);
        assert_bufs_equal (mk_buf "2345" 0) buf;
        assert_chars_equal '2' (Parse_buf.consume_char buf);
        assert_bufs_equal (mk_buf "345" 0) buf
      );

    "test_consume_char_with_bits" >:: (fun ctx ->
        let buf = mk_buf "12345" 1 in
        assert_chars_equal '2' (Parse_buf.consume_char buf);
        assert_bufs_equal (mk_buf "345" 0) buf
      );

    "test_consume_str" >:: (fun ctx ->
        let buf = mk_buf "12345" 0 in
        assert_strings_equal "1" (Parse_buf.consume_str buf 1);
        assert_bufs_equal (mk_buf "2345" 0) buf;
        assert_strings_equal "23" (Parse_buf.consume_str buf 2);
        assert_bufs_equal (mk_buf "45" 0) buf
      );

    "test_consume_str_with_bits" >:: (fun ctx ->
        let buf = mk_buf "12345" 1 in
        assert_strings_equal "2" (Parse_buf.consume_str buf 1);
        assert_bufs_equal (mk_buf "345" 0) buf;
        assert_strings_equal "34" (Parse_buf.consume_str buf 2);
        assert_bufs_equal (mk_buf "5" 0) buf
      );

    "test_consume_bit" >:: (fun ctx ->
        let ch = char_of_int (1 + 4 + 8 + 32) in
        let str = Printf.sprintf "%c%cfoo" ch ch in
        let buf = mk_buf str 0 in
        let assert_consume_bit expected str bits =
          let bit = Parse_buf.consume_bit buf in
          assert_equal ~printer:(fun (bit, buf) ->
              Printf.sprintf "(%B %S %d)" bit buf.Parse_buf.str buf.Parse_buf.bits)
            (expected, mk_buf str bits) (bit, buf)
        in
        assert_consume_bit true str 1;
        assert_consume_bit false str 2;
        assert_consume_bit true str 3;
        assert_consume_bit true str 4;
        assert_consume_bit false str 5;
        assert_consume_bit true str 6;
        assert_consume_bit false str 7;
        assert_consume_bit false str 8;
        assert_consume_bit true (Printf.sprintf "%cfoo" ch) 1;
        assert_consume_bit false (Printf.sprintf "%cfoo" ch) 2;
        assert_consume_bit true (Printf.sprintf "%cfoo" ch) 3;
        assert_consume_bit true (Printf.sprintf "%cfoo" ch) 4;
        assert_consume_bit false (Printf.sprintf "%cfoo" ch) 5;
        assert_consume_bit true (Printf.sprintf "%cfoo" ch) 6;
        assert_consume_bit false (Printf.sprintf "%cfoo" ch) 7;
        assert_consume_bit false (Printf.sprintf "%cfoo" ch) 8
      );

    (* TODO: More tests. *)

  ]


let tests =
  "test_parse_utils" >::: [
    parse_buf_tests;
    (* TODO: More tests. *)
  ]
