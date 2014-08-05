
type client
type channel


module Client : sig
  type t = client

  val connect : server:string -> ?port:int -> unit -> t Lwt.t
  val wait_for_shutdown : t -> unit Lwt.t

  val new_channel : t -> channel Lwt.t
end


module Channel : sig
  type t = channel

  val get_client : t -> client

  val get_channel_number : t -> int

  val get_frame_payload : t -> Frame.payload option Lwt.t
end
