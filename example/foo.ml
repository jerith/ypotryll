
open Lwt
open Ypotryll


let callback channel frame_payload =
  Lwt_io.printlf "<<< %s" (Frame.frame_to_string (channel, frame_payload))


let lwt_main =
  lwt client = Client.connect "localhost" () in
  lwt channel = Client.new_channel client in
  Channel.get_frame_payload channel
  >>= (function
      | None -> return ()
      | Some frame_payload -> callback (Channel.get_channel_number channel) frame_payload) >>
  Client.wait_for_shutdown client


let () = Lwt_main.run lwt_main
