(* This file is generated. See the code_gen dir for details. *)


let frame_end = 206

type frame_type =
  | Method
  | Header
  | Body
  | Heartbeat

let byte_to_frame_type = function
  | 1 -> Method
  | 2 -> Header
  | 3 -> Body
  | 8 -> Heartbeat
  | i -> failwith (Printf.sprintf "Unexpected frame type: %d" i)

let emit_frame_type = function
  | Method -> String.make 1 (char_of_int 1)
  | Header -> String.make 1 (char_of_int 2)
  | Body -> String.make 1 (char_of_int 3)
  | Heartbeat -> String.make 1 (char_of_int 8)
