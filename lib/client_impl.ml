
open Lwt

open Generated_methods


type channel = {
  channel_io : Connection.channel_io;
  connection : Connection.t;
}


let connect = Connection.connect

let close_connection = Connection.close_connection


let wait_for_shutdown connection =
  waiter_of_wakener connection.Connection.finished


let new_channel connection =
  Connection.new_channel connection
  >|= (fun channel_io -> { channel_io; connection })
