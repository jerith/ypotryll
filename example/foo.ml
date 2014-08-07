
open Lwt
open Ypotryll

open Generated_methods


let callback channel frame_payload =
  Lwt_io.printlf "Received frame: %s" (Frame.dump_payload frame_payload)


let rec catch_frames channel =
  Channel.get_frame_payload channel
  >>= function
  | None -> return ()
  | Some frame_payload ->
    callback (Channel.get_channel_number channel) frame_payload >>
    catch_frames channel


let do_stuff client =
  lwt channel = Client.new_channel client in
  ignore_result (catch_frames channel);
  Channel.send_method_sync channel (
    Exchange_declare.make_t
      ~exchange:"foo" ~type_:"direct" ~passive:false ~durable:false
      ~no_wait:false ~arguments:[] ())
  >>= (fun x -> Lwt_io.printlf "Exchange created.") >>
  Client.close_connection client


let lwt_main =
  lwt client = Client.connect ~server:"localhost" () in
  try_lwt
    do_stuff client <&> Client.wait_for_shutdown client
  with Failure text -> Lwt_io.printlf "exception: %S" text >> return ()


let () = Lwt_main.run lwt_main
