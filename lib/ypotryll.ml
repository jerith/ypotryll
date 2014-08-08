
open Lwt


type connection = Connection.t


type channel = {
  channel_io : Connection.channel_io;
  connection : Connection.t;
}


let connect = Connection.connect

let close_connection = Connection.close_connection


let wait_for_shutdown connection =
  waiter_of_wakener connection.Connection.finished


let open_channel connection =
  Connection.new_channel connection
  >|= (fun channel_io -> { channel_io; connection })


let get_connection channel =
  channel.connection


let get_channel_number channel =
  channel.channel_io.Connection.channel


let get_frame_payload channel =
  Lwt_stream.get channel.channel_io.Connection.stream


let send_method_async channel payload =
  Connection.send_method_async channel.channel_io payload


let send_method_sync channel payload =
  Connection.send_method_sync channel.channel_io payload


let close_channel channel =
  Connection.close_channel channel.connection channel.channel_io


module Methods = struct
  module Exchange = struct
    let declare channel ~exchange ~type_ ~passive ~durable ~no_wait ~arguments () =
      send_method_sync channel (Ypotryll_methods.Exchange_declare.make_t ~exchange ~type_ ~passive ~durable ~no_wait ~arguments ())
      >|= function
      | `Exchange_declare_ok payload -> payload
      | _ -> assert false
  end
end
