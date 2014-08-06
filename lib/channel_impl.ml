open Lwt


let get_connection channel =
  channel.Client_impl.connection


let get_channel_number channel =
  channel.Client_impl.channel_io.Connection.channel


let get_frame_payload channel =
  Lwt_stream.get channel.Client_impl.channel_io.Connection.stream


let send_method_async channel payload =
  Client_impl.send_method channel.Client_impl.channel_io payload


let send_method_sync channel payload =
  let (module M : Generated_methods.Method) = Generated_methods.module_for payload in
  let waiter, waker = wait () in
  let channel_io = channel.Client_impl.channel_io in
  channel_io.Connection.expected_responses <-
    channel_io.Connection.expected_responses @ [(M.responses, waker)];
  Client_impl.send_method channel.Client_impl.channel_io payload >>
  waiter
