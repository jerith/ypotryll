
open Lwt


type connection = Connection.t

type channel = Connection.channel


let connect = Connection.connect

let close_connection = Connection.close_connection


let wait_for_shutdown connection =
  waiter_of_wakener connection.Connection.finished


let open_channel connection =
  Connection.new_channel connection
  >|= (fun channel_io -> { Connection.channel_io; connection })


let get_connection channel =
  channel.Connection.connection


let get_io channel =
  channel.Connection.channel_io


let get_channel_number channel =
  (get_io channel).Connection.channel


let get_frame_payload channel =
  Lwt_stream.get (get_io channel).Connection.stream


let send_method_async channel payload =
  Connection.send_method_async (get_io channel) payload


let send_method_sync channel payload =
  Connection.send_method_sync (get_io channel) payload


let close_channel channel =
  Connection.close_channel (get_connection channel) (get_io channel)


module Methods = Generated_caller_modules
