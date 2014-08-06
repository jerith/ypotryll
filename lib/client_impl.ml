
open Lwt

open Generated_methods


type client = {
  connection : Connection.t;
  finished : unit Lwt.t;
}


type channel = {
  channel_io : Connection.channel_io;
  client : client;
}


let client_properties = [
  "copyright", Protocol.Amqp_table.Long_string "Copyright (C) 2014 jerith";
  "information", Protocol.Amqp_table.Long_string "Licensed under the MIT license.";
  "platform", Protocol.Amqp_table.Long_string "OCaml";
  "product", Protocol.Amqp_table.Long_string "ypotryll";
  "version", Protocol.Amqp_table.Long_string "0.0.1";
]


let send_method channel_io method_payload =
  channel_io.Connection.send (Frame.Method method_payload)


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


let failwith_wrong_frame expected frame_payload =
  failwith ("Expected " ^ expected ^ ", got: " ^ Frame.frame_to_string (0, frame_payload))

let process_connection_start channel_io frame_payload =
  (* TODO: Assert channel 0 *)
  let body = match frame_payload with
    | Frame.Method (`Connection_start body) -> body
    | _ -> failwith_wrong_frame "Connection_start" frame_payload
  in
  let mechanism = choose_auth_mechanism body in
  let response = "\000guest\000guest" in
  let locale = choose_locale body in
  Printf.printf "<<< START %s\n%!" (Frame.frame_to_string (0, frame_payload));
  Printf.printf "Auth mechanism: %S\n%!" mechanism;
  Printf.printf "Locales: %S\n%!" locale;
  let frame_ok =
    Connection_start_ok.make_t ~client_properties ~mechanism ~response ~locale ()
  in
  send_method channel_io frame_ok
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


let process_connection_tune channel_io frame_payload =
  (* TODO: Assert channel 0 *)
  let body = match frame_payload with
    | Frame.Method (`Connection_tune body) -> body
    | _ -> failwith_wrong_frame "Connection_tune" frame_payload
  in
  let channel_max = choose_channel_max body in
  let frame_max = choose_frame_max body in
  let heartbeat = choose_heartbeat body in
  Printf.printf "<<< TUNE %s\n%!" (Frame.frame_to_string (0, frame_payload));
  (* Send connection.tune-ok *)
  let frame_ok =
    Connection_tune_ok.make_t ~channel_max ~frame_max ~heartbeat ()
  in
  send_method channel_io frame_ok
  (* Send connection.open *)
  >> let virtual_host = "/" in
  let frame_open =
    Connection_open.make_t ~virtual_host ~reserved_1:"" ~reserved_2:false ()
  in
  send_method channel_io frame_open
  >> return Connection_open


let process_connection_open channel_io frame_payload =
  (* TODO: Assert channel 0 *)
  let _ = match frame_payload with
    | Frame.Method (`Connection_open_ok body) -> body
    | _ -> failwith_wrong_frame "Connection_open_ok" frame_payload
  in
  Printf.printf "<<< OPEN-OK %s\n%!" (Frame.frame_to_string (0, frame_payload));
  return Connected


let vomit_frame frame =
  Printf.printf "<<< %s\n%!" (Frame.frame_to_string frame)


let process_setup_frame_payload channel_io frame_payload = function
  | Connection_start -> process_connection_start channel_io frame_payload
  | Connection_secure -> failwith "Unexpected Connection_secure state."
  | Connection_tune -> process_connection_tune channel_io frame_payload
  | Connection_open -> process_connection_open channel_io frame_payload
  | Connected -> return Connected


let rec setup_connection connection state =
  let channel_io = Hashtbl.find connection.Connection.channels 0 in
  Lwt_stream.get channel_io.Connection.stream
  >>= function
  | None -> return ()
  | Some frame_payload -> process_setup_frame_payload channel_io frame_payload state
  >>= function
  | Connected -> return ()
  | state -> setup_connection connection state


let connect ~server ?port () =
  lwt connection = Connection.connect ~server ?port () in
  setup_connection connection Connection_start >>
  let finished, finished_waker = wait () in
  let client = { connection; finished } in
  return client


let wait_for_shutdown client =
  client.finished


let next_channel channels =
  1 + Hashtbl.fold (fun k _ acc -> max k acc) channels 0


let get_channel client channel =
  Hashtbl.find client.connection.Connection.channels channel


let new_channel client =
  let channel = next_channel client.connection.Connection.channels in
  Connection.create_channel client.connection channel;
  let channel_io = get_channel client channel in
  channel_io.Connection.send (Frame.Method (`Channel_open {
      Channel_open.reserved_1 = "";
    })) >>
  return { channel_io; client }
