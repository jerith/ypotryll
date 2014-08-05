
open Lwt

open Generated_methods


type channel_io = {
  stream : Frame.t Lwt_stream.t;
  push : Frame.t option -> unit;
  send : Frame.t -> unit Lwt.t;
}


type client_io = {
  connection : Connection.t;
  channels : (int, channel_io) Hashtbl.t;
}


type client = {
  client_io : client_io;
  listener : unit Lwt.t;
}


type channel = {
  channel : int;
  channel_io : channel_io;
  client : client;
}


let write_data client_io = Connection.write_data client_io.connection


let client_properties = [
  "copyright", Protocol.Amqp_table.Long_string "Copyright (C) 2014 jerith";
  "information", Protocol.Amqp_table.Long_string "Licensed under the MIT license.";
  "platform", Protocol.Amqp_table.Long_string "OCaml";
  "product", Protocol.Amqp_table.Long_string "ypotryll";
  "version", Protocol.Amqp_table.Long_string "0.0.1";
]


type protocol_state =
  | Connection_start
  | Connection_secure (* Not used currently. *)
  | Connection_tune
  | Connection_open
  | Connected
  | Disconnected


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


let process_connection_start client_io frame =
  (* TODO: Assert channel 0 *)
  let body = match frame with
    | Frame.Method (channel, `Connection_start body) -> body
    | _ -> failwith ("Expected Connection_start, got: " ^ Frame.frame_to_string frame)
  in
  let mechanism = choose_auth_mechanism body in
  let response = "\000guest\000guest" in
  let locale = choose_locale body in
  Printf.printf "<<< START %s\n%!" (Frame.frame_to_string frame);
  Printf.printf "Auth mechanism: %S\n%!" mechanism;
  Printf.printf "Locales: %S\n%!" locale;
  let frame_ok_str = Frame.build_method_frame 0 (`Connection_start_ok {
      Connection_start_ok.client_properties = client_properties;
      Connection_start_ok.mechanism;
      Connection_start_ok.response;
      Connection_start_ok.locale;
    })
  in
  write_data client_io frame_ok_str
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


let process_connection_tune client_io frame =
  (* TODO: Assert channel 0 *)
  let body = match frame with
    | Frame.Method (channel, `Connection_tune body) -> body
    | _ -> failwith ("Expected Connection_tune, got: " ^ Frame.frame_to_string frame)
  in
  let channel_max = choose_channel_max body in
  let frame_max = choose_frame_max body in
  let heartbeat = choose_heartbeat body in
  Printf.printf "<<< TUNE %s\n%!" (Frame.frame_to_string frame);
  (* Send connection.tune-ok *)
  let frame_ok_str = Frame.build_method_frame 0 (`Connection_tune_ok {
      Connection_tune_ok.channel_max;
      Connection_tune_ok.frame_max;
      Connection_tune_ok.heartbeat;
    })
  in
  write_data client_io frame_ok_str
  (* Send connection.open *)
  >> let virtual_host = "/" in
  let frame_open = Frame.build_method_frame 0 (`Connection_open {
      Connection_open.virtual_host;
      Connection_open.reserved_1 = "";
      Connection_open.reserved_2 = false;
    })
  in
  write_data client_io frame_open
  >> return Connection_open


let channel_send client_io channel frame =
  if Hashtbl.mem client_io.channels channel
  then Connection.write_data client_io.connection (Frame.frame_to_string frame)
  else failwith ("Channel not found: " ^ string_of_int channel)


let create_channel client_io channel =
  let stream, push = Lwt_stream.create () in
  let send = channel_send client_io channel in
  Hashtbl.add client_io.channels channel { stream; push; send }


let process_connection_open client_io frame =
  (* TODO: Assert channel 0 *)
  let _ = match frame with
    | Frame.Method (channel, `Connection_open_ok body) -> body
    | _ -> failwith ("Expected Connection_open_ok, got: " ^ Frame.frame_to_string frame)
  in
  Printf.printf "<<< OPEN-OK %s\n%!" (Frame.frame_to_string frame);
  create_channel client_io 0;
  return Connected


let vomit_frame frame state =
  Printf.printf "<<< %s\n%!" (Frame.frame_to_string frame);
  return state


let process_frame client_io frame = function
  | Connection_start -> process_connection_start client_io frame
  | Connection_secure -> failwith "Unexpected Connection_secure state."
  | Connection_tune -> process_connection_tune client_io frame
  | Connection_open -> process_connection_open client_io frame
  | Connected -> vomit_frame frame Connected
  | Disconnected -> failwith "Disconnected."


let rec process_frames client_io str state =
  (* TODO: Avoid waiting here. *)
  let frame, str = Frame.consume_frame str in
  match frame with
  | None -> return (str, state)
  | Some frame -> begin
      process_frame client_io frame state
      >>= process_frames client_io str
    end



let listen client_io =
  let rec listen' ~state ~buffer =
    (* Read some data into our string. *)
    Lwt_io.read ~count:1024 client_io.connection.Connection.inch
    >>= (fun input ->
        Lwt_io.printlf "Read bytes: %d" (String.length input) >>
        Lwt_io.hexdump Lwt_io.stdout input >>
        Lwt_io.flush Lwt_io.stdout >>
        if String.length input = 0 (* EOF from server - we have quit or been kicked. *)
        then return Disconnected
        else begin
          Buffer.add_string buffer input;
          process_frames client_io (Buffer.contents buffer) state
          >>= (fun (remaining_data, state) ->
              Buffer.reset buffer;
              Buffer.add_string buffer remaining_data;
              return state)
        end)
    >>= function
    | Disconnected -> return ()
    | state -> listen' ~state ~buffer
  in
  listen' ~state:Connection_start ~buffer:(Buffer.create 0)


let connect ~server ?port () =
  lwt connection = Connection.connect ~server ?port () in
  Connection.write_data connection "AMQP\x00\x00\x09\x01" >>
  let channels = Hashtbl.create 10 in
  let client_io = { connection; channels } in
  let listener = listen client_io in
  return { client_io; listener }


let wait_for_shutdown client =
  client.listener


let get_channel_client channel =
  channel.client
