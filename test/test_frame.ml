open OUnit2


let make_method channel method_payload =
  (channel, Frame.Method method_payload)


let tests =
  "test_frame" >::: [

    "test_round_trip_connection_start_ok" >:: (fun ctx ->
       let open Ypotryll_types.Table in
        let
          fields = (`Connection_start_ok {
           Ypotryll_methods.Connection_start_ok.
             client_properties = [
             "copyright", Long_string "Copyright (C) 2014 jerith";
             "information", Long_string "Licensed under the MIT license.";
             "platform", Long_string "OCaml";
             "product", Long_string "ypotryll";
             "version", Long_string "0.0.1";
           ];
           mechanism = "PLAIN";
           response = "\000guest\000guest";
           locale = "en_US";
          })
        in
        let wire = Frame.build_frame (make_method 0 fields) in
        let frame_opt, str_left = Frame.consume_frame wire in
        assert_equal ~printer:(Printf.sprintf "%S") "" str_left;
        match frame_opt with
        | None -> assert_failure "Expected Some frame, got None."
        | Some frame -> assert_equal (0, Frame.Method fields) frame
      );

    (* TODO: More tests. *)

  ]
