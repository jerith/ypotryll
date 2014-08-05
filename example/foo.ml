
open Lwt
open Ypotryll


let callback frame =
  Lwt_io.printlf "<<< %s" (Frame.frame_to_string frame)

let lwt_main =
  lwt client = Client.connect "localhost" () in
  Client.wait_for_shutdown client


let () = Lwt_main.run lwt_main
