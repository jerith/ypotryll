open Lwt

open Ypotryll.Methods


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
  Exchange.declare channel
    ~exchange ~type_ ~passive:false ~durable:false ~no_wait:false ~arguments:[]
    ()
  >>= fun _ ->
  Lwt_io.printlf "Exchange created: %s" exchange


let queue_declare channel queue =
  Queue.declare channel
    ~queue ~passive:false ~durable:false ~exclusive:false ~auto_delete:false
    ~no_wait:false ~arguments:[] ()
  >>= fun { Ypotryll_methods.Queue_declare_ok.queue } ->
  Lwt_io.printlf "queue created: %s" queue


let do_stuff client =
  try_lwt
    lwt channel = Ypotryll.open_channel client in
    (* ignore_result (catch_frames channel); *)
    exchange_declare channel "foo" "direct" >>
    queue_declare channel "" >>
    Basic.publish channel ~exchange:"foo" ~routing_key:"bar" ~mandatory:true
      ~immediate:false (Ypotryll_contents.Basic.make_t ()) "stuff" >>
    Lwt_unix.sleep 1. >>
    Ypotryll.close_channel channel >>
    exchange_declare channel "foo" "direct"
  finally Ypotryll.close_connection client


let lwt_main =
  lwt client = Ypotryll.connect ~server:"localhost" () in
  try_lwt
    do_stuff client <&> Ypotryll.wait_for_shutdown client
  with Failure text -> Lwt_io.printlf "exception: %S" text >> return ()


let () = Lwt_main.run lwt_main
