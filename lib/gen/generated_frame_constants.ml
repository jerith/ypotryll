(* This file is generated. See the code_gen dir for details. *)


let frame_end = 206

type frame_type =
  | Method_frame
  | Header_frame
  | Body_frame
  | Heartbeat_frame

let byte_to_frame_type = function
  | 1 -> Method_frame
  | 2 -> Header_frame
  | 3 -> Body_frame
  | 8 -> Heartbeat_frame
  | i -> failwith (Printf.sprintf "Unexpected frame type: %d" i)

let emit_frame_type = function
  | Method_frame -> String.make 1 (char_of_int 1)
  | Header_frame -> String.make 1 (char_of_int 2)
  | Body_frame -> String.make 1 (char_of_int 3)
  | Heartbeat_frame -> String.make 1 (char_of_int 8)
