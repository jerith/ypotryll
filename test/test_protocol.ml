open OUnit2

open Parse_utils
open Protocol


module FT = Field_type
module AF = Amqp_field


let pr_pbuf buf =
  Printf.sprintf "{ str = %S; bits = %d }" buf.Parse_buf.str buf.Parse_buf.bits


let mk_pbuf str bits =
  { Parse_buf.str; Parse_buf.bits }


let pr_bbuf buf =
  Printf.sprintf "{ str = %S; bits = %d }" buf.Build_buf.str buf.Build_buf.bits


let mk_bbuf str bits =
  { Build_buf.str; Build_buf.bits }


let pr_proplist proplist =
  let pr_prop (name, prop_opt) =
    match prop_opt with
    | None -> Printf.sprintf "<Missing %s>" name
    | Some prop -> AF.dump_field (name, prop)
  in
  Printf.sprintf "[%s]" (String.concat "; " (List.map pr_prop proplist))


let str_of_bits bits =
  String.make 1 (char_of_int bits)


let assert_pbufs_equal = assert_equal ~printer:pr_pbuf

let assert_bbufs_equal = assert_equal ~printer:pr_bbuf

let assert_proplists_equal = assert_equal ~printer:pr_proplist

let assert_strings_equal = assert_equal ~printer:(Printf.sprintf "%S")

let assert_ints_equal = assert_equal ~printer:(Printf.sprintf "%d")

let assert_chars_equal = assert_equal ~printer:(Printf.sprintf "%C")

let assert_bools_equal = assert_equal ~printer:(Printf.sprintf "%B")

let assert_all assertion values =
  List.iter (fun (expected, real) -> assertion expected real) values


let make_list f n =
  let rec make_list' made = function
    | 0 -> made
    | i -> make_list' (f i :: made) (i - 1)
  in
  make_list' [] n


let header_utils_tests =
  "test_header_utils" >::: [

    "test_parse_properties_empty" >:: (fun ctx ->
        assert_all assert_proplists_equal [
          [], (Header_utils.parse_properties [] (mk_pbuf "\x00\x00" 0));
          [("field", None)],
          (Header_utils.parse_properties
             [("field", FT.Octet)] (mk_pbuf "\x00\x00" 0));
          [("f1", None); ("f2", None)],
          (Header_utils.parse_properties
             [("f1", FT.Octet); ("f2", FT.Longstring)] (mk_pbuf "\x00\x00" 0));
          [("f1", None); ("f2", None)],
          (Header_utils.parse_properties
             [("f1", FT.Octet); ("f2", FT.Longstring)] (mk_pbuf "\x00\x00" 0));
          (make_list (fun i -> (Printf.sprintf "f%d" i, None)) 15),
          (Header_utils.parse_properties
             (make_list (fun i -> (Printf.sprintf "f%d" i, FT.Octet)) 15)
             (mk_pbuf "\x00\x00" 0));
          (make_list (fun i -> (Printf.sprintf "f%d" i, None)) 16),
          (Header_utils.parse_properties
             (make_list (fun i -> (Printf.sprintf "f%d" i, FT.Octet)) 16)
             (mk_pbuf "\x00\x01\x00\x00" 0));
          (make_list (fun i -> (Printf.sprintf "f%d" i, None)) 30),
          (Header_utils.parse_properties
             (make_list (fun i -> (Printf.sprintf "f%d" i, FT.Octet)) 30)
             (mk_pbuf "\x00\x01\x00\x00" 0));
          (make_list (fun i -> (Printf.sprintf "f%d" i, None)) 31),
          (Header_utils.parse_properties
             (make_list (fun i -> (Printf.sprintf "f%d" i, FT.Octet)) 31)
             (mk_pbuf "\x00\x01\x00\x01\x00\x00" 0));
        ]
      );

    "test_parse_properties_bits" >:: (fun ctx ->
        assert_all assert_proplists_equal [
          [("field", Some (AF.Bit false))],
          (Header_utils.parse_properties
             [("field", FT.Bit)] (mk_pbuf "\x00\x00" 0));
          [("field", Some (AF.Bit true))],
          (Header_utils.parse_properties
             [("field", FT.Bit)] (mk_pbuf "\x80\x00" 0));
          [("f1", Some (AF.Bit false)); ("f2", Some (AF.Bit true))],
          (Header_utils.parse_properties
             [("f1", FT.Bit); ("f2", FT.Bit)] (mk_pbuf "\x40\x00" 0));
        ]
      );

    "test_parse_properties_mixed" >:: (fun ctx ->
        assert_all assert_proplists_equal [
          [("field", Some (AF.Octet 127))],
          (Header_utils.parse_properties
             [("field", FT.Octet)] (mk_pbuf "\x80\x00\x7f" 0));
          [("f1", Some (AF.Bit true)); ("f2", Some (AF.Octet 127))],
          (Header_utils.parse_properties
             [("f1", FT.Bit); ("f2", FT.Octet)] (mk_pbuf "\xc0\x00\x7f" 0));
          [("f1", Some (AF.Bit false)); ("f2", Some (AF.Octet 127))],
          (Header_utils.parse_properties
             [("f1", FT.Bit); ("f2", FT.Octet)] (mk_pbuf "\x40\x00\x7f" 0));
          [("f1", Some (AF.Short 257)); ("f2", Some (AF.Octet 127))],
          (Header_utils.parse_properties
             [("f1", FT.Short); ("f2", FT.Octet)]
             (mk_pbuf "\xc0\x00\x01\x01\x7f" 0));
          [("f1", None); ("f2", Some (AF.Octet 127))],
          (Header_utils.parse_properties
             [("f1", FT.Short); ("f2", FT.Octet)] (mk_pbuf "\x40\x00\x7f" 0));
        ]
      );

    "test_parse_properties_bad_flags" >:: (fun ctx ->
        assert_raises (Failure "End of properties, but not property flags.")
          (fun () -> Header_utils.parse_properties
              [] (mk_pbuf "\x00\x01\x00\x00" 0));
        assert_raises (Failure "End of property flags, but not properties.")
          (fun () -> Header_utils.parse_properties
              (make_list (fun i -> (Printf.sprintf "f%d" i, FT.Octet)) 16)
              (mk_pbuf "\x00\x00" 0));
      );

    "test_build_properties_empty" >:: (fun ctx ->
        assert_all assert_strings_equal [
          "\x00\x00", (Header_utils.build_properties []);
          "\x00\x00", (Header_utils.build_properties [("field", None)]);
          "\x00\x00", (
            Header_utils.build_properties [("f1", None); ("f2", None)]);
          "\x00\x00", (
            Header_utils.build_properties
              (make_list (fun i -> (Printf.sprintf "f%d" i, None)) 15));
          "\x00\x01\x00\x00", (
            Header_utils.build_properties
              (make_list (fun i -> (Printf.sprintf "f%d" i, None)) 16));
        ]
      );

    "test_build_properties_bits" >:: (fun ctx ->
        assert_all assert_strings_equal [
          "\x00\x00", (
            Header_utils.build_properties [("field", Some (AF.Bit false))]);
          "\x80\x00", (
            Header_utils.build_properties [("field", Some (AF.Bit true))]);
          "\x40\x00", (
            Header_utils.build_properties
              [("f1", Some (AF.Bit false)); ("f2", Some (AF.Bit true))]);
        ]
      );

    "test_build_properties_mixed" >:: (fun ctx ->
        assert_all assert_strings_equal [
          "\x80\x00\x7f", (
            Header_utils.build_properties [("field", Some (AF.Octet 127))]);
          "\xc0\x00\x7f", (
            Header_utils.build_properties
              [("f1", Some (AF.Bit true)); ("f2", Some (AF.Octet 127))]);
          "\x40\x00\x7f", (
            Header_utils.build_properties
              [("f1", Some (AF.Bit false)); ("f2", Some (AF.Octet 127))]);
          "\xc0\x00\x01\x01\x7f", (
            Header_utils.build_properties
              [("f1", Some (AF.Short 257)); ("f2", Some (AF.Octet 127))]);
          "\x40\x00\x7f", (
            Header_utils.build_properties
              [("f1", None); ("f2", Some (AF.Octet 127))]);
        ]
      );

    (* TODO: More tests. *)

  ]


let tests =
  "test_protocol" >::: [
    header_utils_tests;
    (* TODO: More tests. *)
  ]
