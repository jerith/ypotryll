
type connection_t

val write_data : connection_t -> string -> unit Lwt.t

val connect :
  addr:Lwt_unix.inet_addr -> ?port:int -> unit -> connection_t Lwt.t

val connect_by_name :
  server:string -> ?port:int -> unit -> connection_t option Lwt.t

val listen : connection_t -> (Frame.frame -> 'a Lwt.t) -> unit Lwt.t
