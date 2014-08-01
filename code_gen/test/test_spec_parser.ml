open OUnit2


let tmpfile_of_string ctx data =
  let name, ouch = bracket_tmpfile ctx in
  output_string ouch data;
  flush ouch;
  name

let channel_of_string ctx data =
  open_in_bin (tmpfile_of_string ctx data)

let valid_amqp_tag =
  "<amqp major=\"1\" minor=\"2\" revision=\"3\" port=\"4\" comment=\"(* foo *)\">"


let tests =
  "test_spec_parser" >::: [

    "test_empty_spec" >:: (fun ctx ->
        let spec_channel = channel_of_string ctx "" in
        assert_raises
          (Failure "XML error at line 1 char 1: unexpected end of input")
          (fun () -> Spec_parser.parse_spec_from_channel spec_channel)
      );

    "test_wrong_root_element" >:: (fun ctx ->
        let spec_channel = channel_of_string ctx "<foo/>" in
        assert_raises
          (Failure "Root element is not <amqp> tag. Is this an AMQP spec?")
          (fun () -> Spec_parser.parse_spec_from_channel spec_channel)
      );

    "test_missing_attr" >:: (fun ctx ->
        let spec_channel = channel_of_string ctx "<amqp/>" in
        assert_raises
          (Failure "Attr not found: major")
          (fun () -> Spec_parser.parse_spec_from_channel spec_channel)
      );

    "test_empty_spec" >:: (fun ctx ->
        let spec_channel = channel_of_string ctx (valid_amqp_tag ^ "</amqp>") in
        assert_equal
          (Amqp_spec.Spec.make (1, 2, 3) 4 "(* foo *)")
          (Spec_parser.parse_spec_from_channel spec_channel)
      );

    "test_bad_tag" >:: (fun ctx ->
        let spec_channel = channel_of_string ctx (valid_amqp_tag ^ "<foo bar=\"baz\"/></amqp>") in
        assert_raises
          (Failure "bad tag: <foo bar=\"baz\">")
          (fun () -> Spec_parser.parse_spec_from_channel spec_channel)
      );

    (* TODO: More tests. *)

  ]
