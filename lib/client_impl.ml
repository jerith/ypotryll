
open Lwt

open Generated_methods


type channel = {
  channel_io : Connection.channel_io;
  connection : Connection.t;
}


let connect = Connection.connect


let wait_for_shutdown connection =
  waiter_of_wakener connection.Connection.finished


let next_channel channels =
  1 + Hashtbl.fold (fun k _ acc -> max k acc) channels 0


let get_channel connection channel =
  Hashtbl.find connection.Connection.channels channel


let new_channel connection =
  Connection.new_channel connection
  >|= (fun channel_io -> { channel_io; connection })
