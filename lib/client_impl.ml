
open Lwt

open Generated_methods


type channel_io = {
  channel : int;
  stream : Frame.t Lwt_stream.t;
  push : Frame.t option -> unit;
  send : Frame.payload -> unit Lwt.t;
}


type client = {
  connection : Connection.t;
  listener : unit Lwt.t;
  channels : (int, channel_io) Hashtbl.t;
}


type channel = {
  channel_io : channel_io;
  client : client;
}


let send_frame connection =
  connection.Connection.send


let client_properties = [
  "copyright", Protocol.Amqp_table.Long_string "Copyright (C) 2014 jerith";
  "information", Protocol.Amqp_table.Long_string "Licensed under the MIT license.";
  "platform", Protocol.Amqp_table.Long_string "OCaml";
  "product", Protocol.Amqp_table.Long_string "ypotryll";
  "version", Protocol.Amqp_table.Long_string "0.0.1";
]


type protocol_setup_state =
  | Connection_start
  | Connection_secure (* Not used currently. *)
  | Connection_tune
  | Connection_open
  | Connected


let str_rpartition str ch =
  try
    let pos = String.rindex str ch in
    (String.sub str 0 pos, Some (String.sub str (pos + 1) ((String.length str) - pos - 1)))
  with
  | Not_found -> (str, None)

let split_string str =
  let rec split_string' str bits =
    let prefix, suffix = str_rpartition str ' ' in
    match suffix with
    | None -> prefix :: bits
    | Some suffix -> split_string' prefix (suffix :: bits)
  in
  split_string' str []


let choose_auth_mechanism body =
  let mechanisms = split_string body.Connection_start.mechanisms in
  if List.mem "PLAIN" mechanisms
  then "PLAIN"
  else failwith ("PLAIN not found in mechanisms: " ^ String.concat " " mechanisms)


let choose_locale body =
  let locales = split_string body.Connection_start.locales in
  if List.mem "en_US" locales
  then "en_US"
  else failwith ("en_US not found in locales: " ^ String.concat " " locales)


let process_connection_start connection frame =
  (* TODO: Assert channel 0 *)
  let body = match frame with
    | channel, Frame.Method (`Connection_start body) -> body
    | _ -> failwith ("Expected Connection_start, got: " ^ Frame.frame_to_string frame)
  in
  let mechanism = choose_auth_mechanism body in
  let response = "\000guest\000guest" in
  let locale = choose_locale body in
  Printf.printf "<<< START %s\n%!" (Frame.frame_to_string frame);
  Printf.printf "Auth mechanism: %S\n%!" mechanism;
  Printf.printf "Locales: %S\n%!" locale;
  let frame_ok = Frame.make_method 0 (`Connection_start_ok {
      Connection_start_ok.client_properties = client_properties;
      Connection_start_ok.mechanism;
      Connection_start_ok.response;
      Connection_start_ok.locale;
    })
  in
  send_frame connection frame_ok
  (* If we support auth mechanisms other than PLAIN in the future, we'll need
     to potentially switch to Connection_secure instead. *)
  >> return Connection_tune


let choose_channel_max body =
  body.Connection_tune.channel_max


let choose_frame_max body =
  (* TODO: Check bounds? *)
  body.Connection_tune.frame_max


let choose_heartbeat body =
  body.Connection_tune.heartbeat


let process_connection_tune connection frame =
  (* TODO: Assert channel 0 *)
  let body = match frame with
    | channel, Frame.Method (`Connection_tune body) -> body
    | _ -> failwith ("Expected Connection_tune, got: " ^ Frame.frame_to_string frame)
  in
  let channel_max = choose_channel_max body in
  let frame_max = choose_frame_max body in
  let heartbeat = choose_heartbeat body in
  Printf.printf "<<< TUNE %s\n%!" (Frame.frame_to_string frame);
  (* Send connection.tune-ok *)
  let frame_ok = Frame.make_method 0 (`Connection_tune_ok {
      Connection_tune_ok.channel_max;
      Connection_tune_ok.frame_max;
      Connection_tune_ok.heartbeat;
    })
  in
  send_frame connection frame_ok
  (* Send connection.open *)
  >> let virtual_host = "/" in
  let frame_open = Frame.make_method 0 (`Connection_open {
      Connection_open.virtual_host;
      Connection_open.reserved_1 = "";
      Connection_open.reserved_2 = false;
    })
  in
  send_frame connection frame_open
  >> return Connection_open


let channel_send connection channel frame_payload =
  send_frame connection (channel, frame_payload)


let create_channel connection channels channel =
  let stream, push = Lwt_stream.create () in
  let send = channel_send connection channel in
  Hashtbl.add channels channel { channel; stream; push; send }


let process_connection_open connection frame =
  (* TODO: Assert channel 0 *)
  let _ = match frame with
    | channel, Frame.Method (`Connection_open_ok body) -> body
    | _ -> failwith ("Expected Connection_open_ok, got: " ^ Frame.frame_to_string frame)
  in
  Printf.printf "<<< OPEN-OK %s\n%!" (Frame.frame_to_string frame);
  return Connected


let vomit_frame frame =
  Printf.printf "<<< %s\n%!" (Frame.frame_to_string frame)


let process_setup_frame connection frame = function
  | Connection_start -> process_connection_start connection frame
  | Connection_secure -> failwith "Unexpected Connection_secure state."
  | Connection_tune -> process_connection_tune connection frame
  | Connection_open -> process_connection_open connection frame
  | Connected -> return Connected


let rec setup_connection connection state =
  Lwt_stream.get connection.Connection.stream
  >>= function
  | None -> return ()
  | Some frame -> process_setup_frame connection frame state
  >>= function
  | Connected -> return ()
  | state -> setup_connection connection state


let rec maintain_connection connection channels =
  Lwt_stream.get connection.Connection.stream
  >>= function
  | None -> return ()
  | Some frame -> vomit_frame frame; maintain_connection connection channels


let connect ~server ?port () =
  lwt connection = Connection.connect ~server ?port () in
  let channels = Hashtbl.create 10 in
  setup_connection connection Connection_start >>
  let listener = maintain_connection connection channels in
  return { connection; listener; channels }


let wait_for_shutdown client =
  client.listener


let next_channel channels =
  1 + Hashtbl.fold (fun k _ acc -> max k acc) channels 0


let get_channel client channel =
  Hashtbl.find client.channels channel


let new_channel client =
  let channel = next_channel client.channels in
  create_channel client.connection client.channels channel;
  let channel_io = get_channel client channel in
  channel_io.send (Frame.Method (`Channel_open {
      Channel_open.reserved_1 = "";
    })) >>
  return { channel_io; client }