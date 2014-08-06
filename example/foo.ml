
open Lwt
open Ypotryll

open Generated_methods


let callback channel frame_payload =
  Lwt_io.printlf "<<< %s" (Frame.frame_to_string (channel, frame_payload))


let rec catch_frames channel =
  Channel.get_frame_payload channel
  >>= function
  | None -> return ()
  | Some frame_payload ->
    callback (Channel.get_channel_number channel) frame_payload >>
    catch_frames channel


let lwt_main =
  lwt client = Client.connect "localhost" () in
  lwt channel = Client.new_channel client in
  ignore_result (catch_frames channel);
  Channel.send_method_sync channel (
    Exchange_declare.make_t
      ~exchange:"foo" ~type_:"direct" ~passive:false ~durable:false ~no_wait:false ~arguments:[] ())
  >>= (fun x -> Lwt_io.printlf "XXX" >> return (Frame.Method x))
  >>= callback (Channel.get_channel_number channel) >>
  Client.wait_for_shutdown client


let () = Lwt_main.run lwt_main
