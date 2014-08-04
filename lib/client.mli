
type t

val write_data : t -> string -> unit Lwt.t

val connect :
  server:string -> ?port:int -> unit -> t option Lwt.t

val listen : t -> (Frame.t -> 'a Lwt.t) -> unit Lwt.t
