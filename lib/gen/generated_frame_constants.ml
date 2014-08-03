(* This file is generated. See the code_gen dir for details. *)


let frame_end = 206

type frame_type =
  | Method
  | Header
  | Body
  | Heartbeat

let byte_to_frame_type = function| 1 -> Method
  | 2 -> Header
  | 3 -> Body
  | 8 -> Heartbeat
  | i -> failwith (Printf.sprintf "Unexpected frame type: %d" i)
