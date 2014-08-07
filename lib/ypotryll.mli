
type connection
type channel
type method_payload = Generated_method_types.method_payload


val connect : server:string -> ?port:int -> ?log_section:Lwt_log.section
  -> unit -> connection Lwt.t

val close_connection : connection -> unit Lwt.t

val wait_for_shutdown : connection -> unit Lwt.t

val open_channel : connection -> channel Lwt.t

val get_channel_number : channel -> int

val close_channel : channel -> unit Lwt.t

(* TEMP? *)

val get_frame_payload : channel -> Frame.payload option Lwt.t

val send_method_async : channel -> method_payload -> unit Lwt.t

val send_method_sync : channel -> method_payload -> method_payload Lwt.t
