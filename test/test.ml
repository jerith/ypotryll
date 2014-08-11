open OUnit2


let tests =
  "tests" >::: [
    Test_parse_utils.tests;
    Test_protocol.tests;
    Test_frame.tests;
  ]

let () = run_test_tt_main tests
