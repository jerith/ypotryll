
open Lwt

let callback frame =
  Lwt_io.printlf "<<< %s" (Frame.frame_to_string frame)

let lwt_main =
  Ypotryll.Client.connect "localhost" ()
  >>= Ypotryll.Client.wait_for_shutdown


let () = Lwt_main.run lwt_main
