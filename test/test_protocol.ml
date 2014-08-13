open OUnit2

open Parse_utils
open Protocol


module FT = Field_type


let mk_pbuf str bits =
  { Parse_buf.str; Parse_buf.bits }


let pr_proplist proplist =
  let pr_prop (name, prop_opt) =
    match prop_opt with
    | None -> Printf.sprintf "<Missing %s>" name
    | Some prop -> Amqp_field.dump_field (name, prop)
  in
  Printf.sprintf "[%s]" (String.concat "; " (List.map pr_prop proplist))


let assert_proplists_equal = assert_equal ~printer:pr_proplist

let assert_strings_equal = assert_equal ~printer:(Printf.sprintf "%S")

let assert_all assertion values =
  List.iter (fun (expected, real) -> assertion expected real) values


let make_plist value n =
  let rec make_list' made = function
    | 0 -> made
    | i -> make_list' ((Printf.sprintf "f%d" i, value) :: made) (i - 1)
  in
  make_list' [] n


let some_bit value =
  Some (Amqp_field.Bit value)

let some_octet value =
  Some (Amqp_field.Octet value)

let some_short value =
  Some (Amqp_field.Short value)


let parse_props properties buf_str =
  Header_utils.buf_to_list properties (mk_pbuf buf_str 0)

let build_props properties =
  Header_utils.build_properties properties


let header_utils_tests =
  "test_header_utils" >::: [

    "test_parse_properties_empty" >:: (fun ctx ->
        assert_all assert_proplists_equal [
          [], (parse_props [] "\x00\x00");
          [("field", None)], (parse_props [("field", FT.Octet)] "\x00\x00");
          [("f1", None); ("f2", None)], (
            parse_props [("f1", FT.Octet); ("f2", FT.Longstring)] "\x00\x00");
          [("f1", None); ("f2", None)], (
            parse_props [("f1", FT.Octet); ("f2", FT.Longstring)] "\x00\x00");
          (make_plist None 15), (
            parse_props (make_plist FT.Octet 15) "\x00\x00");
          (make_plist None 16), (
            parse_props (make_plist FT.Octet 16) "\x00\x01\x00\x00");
          (make_plist None 30), (
            parse_props (make_plist FT.Octet 30) "\x00\x01\x00\x00");
          (make_plist None 31), (
            parse_props (make_plist FT.Octet 31) "\x00\x01\x00\x01\x00\x00");
        ]
      );

    "test_parse_properties_bits" >:: (fun ctx ->
        assert_all assert_proplists_equal [
          [("field", some_bit false)], (
            parse_props [("field", FT.Bit)] "\x00\x00");
          [("field", some_bit true)], (
            parse_props [("field", FT.Bit)] "\x80\x00");
          [("f1", some_bit false); ("f2", some_bit true)], (
            parse_props [("f1", FT.Bit); ("f2", FT.Bit)] "\x40\x00");
        ]
      );

    "test_parse_properties_mixed" >:: (fun ctx ->
        assert_all assert_proplists_equal [
          [("field", some_octet 127)], (
            parse_props [("field", FT.Octet)] "\x80\x00\x7f");
          [("f1", some_bit true); ("f2", some_octet 127)], (
            parse_props [("f1", FT.Bit); ("f2", FT.Octet)] "\xc0\x00\x7f");
          [("f1", some_bit false); ("f2", some_octet 127)], (
            parse_props [("f1", FT.Bit); ("f2", FT.Octet)] "\x40\x00\x7f");
          [("f1", some_short 257); ("f2", some_octet 127)], (
            parse_props
              [("f1", FT.Short); ("f2", FT.Octet)] "\xc0\x00\x01\x01\x7f");
          [("f1", None); ("f2", some_octet 127)], (
            parse_props [("f1", FT.Short); ("f2", FT.Octet)] "\x40\x00\x7f");
        ]
      );

    "test_parse_properties_bad_flags" >:: (fun ctx ->
        assert_raises (Failure "End of properties, but not property flags.")
          (fun () -> parse_props [] "\x00\x01\x00\x00");
        assert_raises (Failure "End of property flags, but not properties.")
          (fun () -> parse_props (make_plist FT.Octet 16) "\x00\x00");
      );

    "test_build_properties_empty" >:: (fun ctx ->
        assert_all assert_strings_equal [
          "\x00\x00", (build_props []);
          "\x00\x00", (build_props [("field", None)]);
          "\x00\x00", (build_props [("f1", None); ("f2", None)]);
          "\x00\x00", (build_props (make_plist None 15));
          "\x00\x01\x00\x00", (build_props (make_plist None 16));
        ]
      );

    "test_build_properties_bits" >:: (fun ctx ->
        assert_all assert_strings_equal [
          "\x00\x00", (build_props [("field", some_bit false)]);
          "\x80\x00", (build_props [("field", some_bit true)]);
          "\x40\x00", (
            build_props [("f1", some_bit false); ("f2", some_bit true)]);
        ]
      );

    "test_build_properties_mixed" >:: (fun ctx ->
        assert_all assert_strings_equal [
          "\x80\x00\x7f", (build_props [("field", some_octet 127)]);
          "\xc0\x00\x7f", (
            build_props [("f1", some_bit true); ("f2", some_octet 127)]);
          "\x40\x00\x7f", (
            build_props [("f1", some_bit false); ("f2", some_octet 127)]);
          "\xc0\x00\x01\x01\x7f", (
            build_props [("f1", some_short 257); ("f2", some_octet 127)]);
          "\x40\x00\x7f", (build_props [("f1", None); ("f2", some_octet 127)]);
        ]
      );

    (* TODO: More tests. *)

  ]


let tests =
  "test_protocol" >::: [
    header_utils_tests;
    (* TODO: More tests. *)
  ]
