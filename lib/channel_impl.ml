open Lwt


let get_connection channel =
  channel.Client_impl.connection


let get_channel_number channel =
  channel.Client_impl.channel_io.Connection.channel


let get_frame_payload channel =
  Lwt_stream.get channel.Client_impl.channel_io.Connection.stream


let send_method_async channel payload =
  Connection.send_method_async channel.Client_impl.channel_io payload


let send_method_sync channel payload =
  Connection.send_method_sync channel.Client_impl.channel_io payload
