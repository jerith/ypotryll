
open Lwt

let callback frame =
  Lwt_io.printlf "<<< %s" (Frame.frame_to_string frame)

let lwt_main =
  Client.connect "localhost" ()
  >>= function
  | None -> return ()
  | Some connection -> Client.listen connection callback


let () = Lwt_main.run lwt_main
