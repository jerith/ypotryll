
type client
type channel
type method_payload = Generated_method_types.method_payload


module Client : sig
  type t = client

  val connect : server:string -> ?port:int -> unit -> t Lwt.t
  val wait_for_shutdown : t -> unit Lwt.t

  val new_channel : t -> channel Lwt.t
end


module Channel : sig
  type t = channel

  val get_connection : t -> client

  val get_channel_number : t -> int

  val get_frame_payload : t -> Frame.payload option Lwt.t

  (* TEMP *)

  val send_method_async : t -> method_payload -> unit Lwt.t

  val send_method_sync : t -> method_payload -> method_payload Lwt.t
end
