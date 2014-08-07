
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


let exchange_declare channel exchange type_ =
  Channel.send_method_sync channel (
    Exchange_declare.make_t
      ~exchange ~type_ ~passive:false ~durable:false ~no_wait:false
      ~arguments:[] ())
  >>= function
  | `Exchange_declare_ok _ -> Lwt_io.printlf "Exchange created: %s" exchange
  | _ -> assert false


let do_stuff client =
  try_lwt
    lwt channel = Client.new_channel client in
    ignore_result (catch_frames channel);
    exchange_declare channel "foo" "direct" >>
    Channel.close channel >>
    exchange_declare channel "foo" "direct"
  finally Client.close_connection client


let lwt_main =
  lwt client = Client.connect ~server:"localhost" () in
  try_lwt
    do_stuff client <&> Client.wait_for_shutdown client
  with Failure text -> Lwt_io.printlf "exception: %S" text >> return ()


let () = Lwt_main.run lwt_main
