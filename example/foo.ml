
open Lwt


(* let callback channel frame_payload = *)
(*   Lwt_io.printlf "Received frame: %s" (Frame.dump_payload frame_payload) *)


(* let rec catch_frames channel = *)
(*   Ypotryll.get_frame_payload channel *)
(*   >>= function *)
(*   | None -> return () *)
(*   | Some frame_payload -> *)
(*     callback (Ypotryll.get_channel_number channel) frame_payload >> *)
(*     catch_frames channel *)


let exchange_declare channel exchange type_ =
    Ypotryll.Methods.Exchange.declare channel
      ~exchange ~type_ ~passive:false ~durable:false ~no_wait:false ~arguments:[] ()
  >>= fun _ ->
  Lwt_io.printlf "Exchange created: %s" exchange


let do_stuff client =
  try_lwt
    lwt channel = Ypotryll.open_channel client in
    (* ignore_result (catch_frames channel); *)
    exchange_declare channel "foo" "direct" >>
    Ypotryll.close_channel channel >>
    exchange_declare channel "foo" "direct"
  finally Ypotryll.close_connection client


let lwt_main =
  lwt client = Ypotryll.connect ~server:"localhost" () in
  try_lwt
    do_stuff client <&> Ypotryll.wait_for_shutdown client
  with Failure text -> Lwt_io.printlf "exception: %S" text >> return ()


let () = Lwt_main.run lwt_main
