open OUnit2

open Generated_methods


let tests =
  "test_frame" >::: [

    "test_round_trip_connection_start_ok" >:: (fun ctx ->
        let
          fields = (`Connection_start_ok {
            Connection_start_ok.client_properties = [
              "copyright", Protocol.Amqp_table.Long_string "Copyright (C) 2014 jerith";
              "information", Protocol.Amqp_table.Long_string "Licensed under the MIT license.";
              "platform", Protocol.Amqp_table.Long_string "OCaml";
              "product", Protocol.Amqp_table.Long_string "ypotryll";
              "version", Protocol.Amqp_table.Long_string "0.0.1";
            ];
            Connection_start_ok.mechanism = "PLAIN";
            Connection_start_ok.response = "\000guest\000guest";
            Connection_start_ok.locale = "en_US";
          })
        in
        let wire = Frame.build_method_frame 0 fields in
        let frame_opt, str_left = Frame.consume_frame wire in
        assert_equal ~printer:(Printf.sprintf "%S") "" str_left;
        match frame_opt with
        | None -> assert_failure "Expected Some frame, got None."
        | Some frame -> assert_equal (Frame.Method (0, fields)) frame
      );

    (* TODO: More tests. *)

  ]
