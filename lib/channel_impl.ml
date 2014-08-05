

let get_client channel =
  channel.Client_impl.client


let get_channel_number channel =
  channel.Client_impl.channel_io.Connection.channel


let get_frame_payload channel =
  Lwt_stream.get channel.Client_impl.channel_io.Connection.stream
