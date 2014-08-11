open OUnit2

open Parse_utils


let pr_pbuf buf =
  Printf.sprintf "{ str = %S; bits = %d }" buf.Parse_buf.str buf.Parse_buf.bits


let mk_pbuf str bits =
  { Parse_buf.str; Parse_buf.bits }


let pr_bbuf buf =
  Printf.sprintf "{ str = %S; bits = %d }" buf.Build_buf.str buf.Build_buf.bits


let mk_bbuf str bits =
  { Build_buf.str; Build_buf.bits }


let str_of_bits bits =
  String.make 1 (char_of_int bits)


let assert_pbufs_equal = assert_equal ~printer:pr_pbuf

let assert_bbufs_equal = assert_equal ~printer:pr_bbuf

let assert_strings_equal = assert_equal ~printer:(Printf.sprintf "%S")

let assert_ints_equal = assert_equal ~printer:(Printf.sprintf "%d")

let assert_chars_equal = assert_equal ~printer:(Printf.sprintf "%C")

let assert_bools_equal = assert_equal ~printer:(Printf.sprintf "%B")

let assert_all assertion values =
  List.iter (fun (expected, real) -> assertion expected real) values


let parse_buf_tests =
  "test_parse_buf" >::: [

    "test_from_string" >:: (fun ctx ->
        assert_all assert_pbufs_equal [
          (mk_pbuf "foo" 0), (Parse_buf.from_string "foo");
          (mk_pbuf "barge" 0), (Parse_buf.from_string "barge");
        ]
      );

    "test_to_string" >:: (fun ctx ->
        assert_strings_equal "foo" (Parse_buf.to_string (mk_pbuf "foo" 0));
        assert_strings_equal "foo" (Parse_buf.to_string (mk_pbuf "foo" 1));
        assert_strings_equal "barge" (Parse_buf.to_string (mk_pbuf "barge" 0))
      );

    "test_length" >:: (fun ctx ->
        assert_ints_equal 3 (Parse_buf.length (mk_pbuf "foo" 0));
        assert_ints_equal 3 (Parse_buf.length (mk_pbuf "foo" 1));
        assert_ints_equal 5 (Parse_buf.length (mk_pbuf "barge" 0))
      );

    "test_advance" >:: (fun ctx ->
        let buf = mk_pbuf "12345" 0 in
        Parse_buf.advance buf 0; assert_pbufs_equal (mk_pbuf "12345" 0) buf;
        Parse_buf.advance buf 1; assert_pbufs_equal (mk_pbuf "2345" 0) buf;
        Parse_buf.advance buf 1; assert_pbufs_equal (mk_pbuf "345" 0) buf;
        Parse_buf.advance buf 2; assert_pbufs_equal (mk_pbuf "5" 0) buf
      );

    "test_advance_with_bits" >:: (fun ctx ->
        let buf = mk_pbuf "12345" 1 in
        Parse_buf.advance buf 1; assert_pbufs_equal (mk_pbuf "2345" 0) buf
      );

    "test_clear_bits" >:: (fun ctx ->
        let buf = mk_pbuf "12345" 0 in
        Parse_buf.clear_bits buf; assert_pbufs_equal (mk_pbuf "12345" 0) buf;
        let buf = mk_pbuf "12345" 1 in
        Parse_buf.clear_bits buf; assert_pbufs_equal (mk_pbuf "2345" 0) buf
      );

    "test_consume_char" >:: (fun ctx ->
        let buf = mk_pbuf "12345" 0 in
        assert_chars_equal '1' (Parse_buf.consume_char buf);
        assert_pbufs_equal (mk_pbuf "2345" 0) buf;
        assert_chars_equal '2' (Parse_buf.consume_char buf);
        assert_pbufs_equal (mk_pbuf "345" 0) buf
      );

    "test_consume_char_with_bits" >:: (fun ctx ->
        let buf = mk_pbuf "12345" 1 in
        assert_chars_equal '2' (Parse_buf.consume_char buf);
        assert_pbufs_equal (mk_pbuf "345" 0) buf
      );

    "test_consume_str" >:: (fun ctx ->
        let buf = mk_pbuf "12345" 0 in
        assert_strings_equal "1" (Parse_buf.consume_str buf 1);
        assert_pbufs_equal (mk_pbuf "2345" 0) buf;
        assert_strings_equal "23" (Parse_buf.consume_str buf 2);
        assert_pbufs_equal (mk_pbuf "45" 0) buf
      );

    "test_consume_str_with_bits" >:: (fun ctx ->
        let buf = mk_pbuf "12345" 1 in
        assert_strings_equal "2" (Parse_buf.consume_str buf 1);
        assert_pbufs_equal (mk_pbuf "345" 0) buf;
        assert_strings_equal "34" (Parse_buf.consume_str buf 2);
        assert_pbufs_equal (mk_pbuf "5" 0) buf
      );

    "test_consume_bit" >:: (fun ctx ->
        let bits = str_of_bits 0b00101101 in
        let buf = mk_pbuf (bits ^ bits ^ "foo") 0 in
        let assert_consume_bit expected str bits =
          let bit = Parse_buf.consume_bit buf in
          assert_equal ~printer:(fun (bit, buf) ->
              Printf.sprintf "(%B %S %d)" bit buf.Parse_buf.str buf.Parse_buf.bits)
            (expected, mk_pbuf str bits) (bit, buf)
        in
        assert_consume_bit true (bits ^ bits ^ "foo") 1;
        assert_consume_bit false (bits ^ bits ^ "foo") 2;
        assert_consume_bit true (bits ^ bits ^ "foo") 3;
        assert_consume_bit true (bits ^ bits ^ "foo") 4;
        assert_consume_bit false (bits ^ bits ^ "foo") 5;
        assert_consume_bit true (bits ^ bits ^ "foo") 6;
        assert_consume_bit false (bits ^ bits ^ "foo") 7;
        assert_consume_bit false (bits ^ bits ^ "foo") 8;
        assert_consume_bit true (bits ^ "foo") 1;
        assert_consume_bit false (bits ^ "foo") 2;
        assert_consume_bit true (bits ^ "foo") 3;
        assert_consume_bit true (bits ^ "foo") 4;
        assert_consume_bit false (bits ^ "foo") 5;
        assert_consume_bit true (bits ^ "foo") 6;
        assert_consume_bit false (bits ^ "foo") 7;
        assert_consume_bit false (bits ^ "foo") 8
      );

  ]

let build_buf_tests =
  "test_build_buf" >::: [

    "test_from_string" >:: (fun ctx ->
        assert_all assert_bbufs_equal [
          (mk_bbuf "foo" 0), (Build_buf.from_string "foo");
          (mk_bbuf "barge" 0), (Build_buf.from_string "barge");
        ]
      );

    "test_to_string" >:: (fun ctx ->
        assert_strings_equal "foo" (Build_buf.to_string (mk_bbuf "foo" 0));
        assert_strings_equal "foo" (Build_buf.to_string (mk_bbuf "foo" 1));
        assert_strings_equal "barge" (Build_buf.to_string (mk_bbuf "barge" 0))
      );

    "test_length" >:: (fun ctx ->
        assert_ints_equal 3 (Build_buf.length (mk_bbuf "foo" 0));
        assert_ints_equal 3 (Build_buf.length (mk_bbuf "foo" 1));
        assert_ints_equal 5 (Build_buf.length (mk_bbuf "barge" 0))
      );

    "test_clear_bits" >:: (fun ctx ->
        let buf = mk_bbuf "12345" 0 in
        Build_buf.clear_bits buf; assert_bbufs_equal (mk_bbuf "12345" 0) buf;
        let buf = mk_bbuf "12345" 1 in
        Build_buf.clear_bits buf; assert_bbufs_equal (mk_bbuf "12345" 0) buf
      );

    "test_add_char" >:: (fun ctx ->
        let buf = mk_bbuf "" 0 in
        Build_buf.add_char buf '1'; assert_bbufs_equal (mk_bbuf "1" 0) buf;
        Build_buf.add_char buf '2'; assert_bbufs_equal (mk_bbuf "12" 0) buf
      );

    "test_add_char_with_bits" >:: (fun ctx ->
        let buf = mk_bbuf "1" 2 in
        Build_buf.add_char buf '2'; assert_bbufs_equal (mk_bbuf "12" 0) buf;
        Build_buf.add_char buf '3'; assert_bbufs_equal (mk_bbuf "123" 0) buf
      );

    "test_add_str" >:: (fun ctx ->
        let buf = mk_bbuf "" 0 in
        Build_buf.add_str buf "1"; assert_bbufs_equal (mk_bbuf "1" 0) buf;
        Build_buf.add_str buf "23"; assert_bbufs_equal (mk_bbuf "123" 0) buf
      );

    "test_add_str_with_bits" >:: (fun ctx ->
        let buf = mk_bbuf "1" 2 in
        Build_buf.add_str buf "2"; assert_bbufs_equal (mk_bbuf "12" 0) buf;
        Build_buf.add_str buf "34"; assert_bbufs_equal (mk_bbuf "1234" 0) buf
      );

    "test_add_bit" >:: (fun ctx ->
        let bits = str_of_bits 0b00101101 in
        let buf = mk_bbuf "foo" 0 in
        let assert_add_bit bit str bits =
          Build_buf.add_bit buf bit;
          assert_equal ~printer:(fun (bit, buf) ->
              Printf.sprintf "(%B %S %d)" bit buf.Build_buf.str buf.Build_buf.bits)
            (bit, mk_bbuf str bits) (bit, buf)
        in
        assert_add_bit true ("foo" ^ str_of_bits 0b00000001) 1;
        assert_add_bit false ("foo" ^ str_of_bits 0b00000001) 2;
        assert_add_bit true ("foo" ^ str_of_bits 0b00000101) 3;
        assert_add_bit true ("foo" ^ str_of_bits 0b00001101) 4;
        assert_add_bit false ("foo" ^ str_of_bits 0b00001101) 5;
        assert_add_bit true ("foo" ^ str_of_bits 0b00101101) 6;
        assert_add_bit false ("foo" ^ str_of_bits 0b00101101) 7;
        assert_add_bit false ("foo" ^ str_of_bits 0b00101101) 8;
        assert_add_bit true ("foo" ^ bits ^ str_of_bits 0b00000001) 1;
        assert_add_bit false ("foo" ^ bits ^ str_of_bits 0b00000001) 2;
        assert_add_bit true ("foo" ^ bits ^ str_of_bits 0b00000101) 3;
        assert_add_bit true ("foo" ^ bits ^ str_of_bits 0b00001101) 4;
        assert_add_bit false ("foo" ^ bits ^ str_of_bits 0b00001101) 5;
        assert_add_bit true ("foo" ^ bits ^ str_of_bits 0b00101101) 6;
        assert_add_bit false ("foo" ^ bits ^ str_of_bits 0b00101101) 7;
        assert_add_bit false ("foo" ^ bits ^ str_of_bits 0b00101101) 8;
      );

  ]


let tests =
  "test_parse_utils" >::: [
    parse_buf_tests;
    build_buf_tests;
    (* TODO: More tests. *)
  ]
