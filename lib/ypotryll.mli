type connection
type channel = Connection.channel
type connect_params = Connection.connect_params


open Ypotryll_types


val make_params : username:string -> password:string -> ?virtual_host:string
    -> unit -> connect_params

val connect : server:string -> ?port:int -> params:connect_params
  -> ?log_section:Lwt_log.section -> unit -> connection Lwt.t

val close_connection : connection -> unit Lwt.t

val wait_for_shutdown : connection -> unit Lwt.t

val open_channel : connection -> channel Lwt.t

val get_channel_number : channel -> int

val close_channel : channel -> unit Lwt.t

val get_method_with_content : channel
  -> (method_payload * (header_payload * string) option) option Lwt.t

(* TEMP? *)

val get_frame_payload : channel -> Frame.payload option Lwt.t

val send_method_async : channel -> method_payload -> unit Lwt.t

val send_method_sync : channel -> method_payload -> method_payload Lwt.t


module Methods : module type of Generated_caller_modules
