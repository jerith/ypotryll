open Lwt

open Generated_methods


type connection_params = {
  locale : string;
  channel_max : int;
  frame_max : int;
  heartbeat : int;
}


type connection_state =
  | Opening
  | Open
  | Closing
  | Closed


let string_of_state = function
  | Opening -> "Opening"
  | Open -> "Open"
  | Closing -> "Closing"
  | Closed -> "Closed"


type connection_io = {
  inch : Lwt_io.input_channel;
  ouch : Lwt_io.output_channel;
  mutable params : connection_params;
  mutable connection_state : connection_state;
}


type expected_response = (int * int) list * Generated_method_types.method_payload Lwt.u


type channel_io = {
  channel : int;
  stream : Frame.payload Lwt_stream.t;
  push : Frame.payload option -> unit;
  send : Frame.payload -> unit Lwt.t;
  mutable expected_responses : expected_response list;
  mutable channel_state : connection_state;
}


type t = {
  connection_io : connection_io;
  connection_send : Frame.t -> unit Lwt.t;
  channels : (int, channel_io) Hashtbl.t;
  finished : unit Lwt.u;
}


let default_params = {
  locale = "en_US";
  channel_max = 0;
  frame_max = 0;
  heartbeat = 0;
}


let debug_dump verb connection_io data =
  if false
  then
    Lwt_io.printlf "%s %d bytes:" verb (String.length data) >>
    Lwt_io.hexdump Lwt_io.stdout data >>
    Lwt_io.flush Lwt_io.stdout
  else return_unit


let gethostbyname name =
  (* May raise Not_found from gethostbyname. *)
  Lwt_unix.gethostbyname name
  >>= (fun entry -> return entry.Unix.h_addr_list.(0))


let write_data conn_io data =
  debug_dump "Sending" conn_io data >>
  Lwt_io.write conn_io.ouch data


let write_frame conn_io frame =
  write_data conn_io (Frame.build_frame frame)


let _set_connection_state connection expected_state new_state =
  let current_state = connection.connection_io.connection_state in
  if current_state = expected_state
  then connection.connection_io.connection_state <- new_state
  else failwith (
      "Can't transition to state " ^ (string_of_state new_state)
      ^ " from " ^ (string_of_state current_state) ^ ".")


let set_connection_state connection = function
  | Opening -> failwith "Can't transition to state Opening."
  | Open -> _set_connection_state connection Opening Open
  | Closing -> _set_connection_state connection Open Closing
  | Closed -> _set_connection_state connection Closing Closed


let create_connection_io server port =
  lwt addr = gethostbyname server in
  Lwt_io.open_connection (Unix.ADDR_INET (addr, port))
  >>= (fun (inch, ouch) ->
      let connection_io =
        { inch; ouch; params = default_params; connection_state = Opening }
      in
      write_data connection_io "AMQP\x00\x00\x09\x01" >>
      Lwt_io.printlf ">>> %S" "AMQP\x00\x00\x09\x01" >>
      return connection_io)


let rec pop_expected_response method_num checked = function
  | [] -> None, List.rev checked
  | (expected, waker) :: responses when List.mem method_num expected ->
    Some waker, List.rev_append checked responses
  | response :: responses ->
    pop_expected_response method_num (response :: checked) responses


let process_channel_method channel_io payload =
  let { Frame.class_id; Frame.method_id } = Frame.method_info payload in
  let expected_responses = channel_io.expected_responses in
  match pop_expected_response (class_id, method_id) [] expected_responses with
  | None, _ -> channel_io.push (Some (Frame.Method payload))
  | Some waker, expected_responses ->
    channel_io.expected_responses <- expected_responses;
    wakeup waker payload


let process_channel_frame connection channel_io = function
  | Frame.Method payload -> process_channel_method channel_io payload; return_unit
  | frame_payload -> channel_io.push (Some frame_payload); return_unit


let rec process_frames connection str =
  let frame, str = Frame.consume_frame str in
  match frame with
  | None -> return str
  | Some (channel, payload) ->
    let channel_io = Hashtbl.find connection.channels channel in
    Lwt_io.printlf "<<<[%d] %s" channel_io.channel (Frame.dump_payload payload) >>
    process_channel_frame connection channel_io payload >>
    process_frames connection str


let kill_connection connection =
  begin match connection.connection_io.connection_state with
    | Opening | Open | Closing ->
      wakeup_exn connection.finished (Failure "Connection closed by peer.")
    | Closed -> wakeup connection.finished ()
  end;
  Lwt_io.printlf "Connection closed."


let listen connection =
  let rec listen' buffer =
    (* Read some data into our string. *)
    begin
      try_lwt
        Lwt_io.read ~count:1024 connection.connection_io.inch
      with
      | Lwt_io.Channel_closed _ -> return ""
    end
    >>= fun input ->
    debug_dump "Received" connection.connection_io input >>
    if String.length input = 0 (* EOF from server. *)
    then kill_connection connection
    else begin
      Buffer.add_string buffer input;
      process_frames connection (Buffer.contents buffer)
      >>= fun remaining_data ->
      Buffer.reset buffer;
      Buffer.add_string buffer remaining_data;
      listen' buffer
    end
  in
  listen' (Buffer.create 0)


let create_channel connection channel channel_state =
  let stream, push = Lwt_stream.create () in
  let send frame_payload =
    Lwt_io.printlf ">>>[%d] %s" channel (Frame.dump_payload frame_payload) >>
    connection.connection_send (channel, frame_payload)
  in
  Hashtbl.add connection.channels channel
    { channel; stream; push; send; expected_responses = []; channel_state }


let send_method_async channel_io payload =
  channel_io.send (Frame.Method payload)


let send_method_sync channel_io payload =
  (* TODO: Figure out what to do with no-wait=true methods. *)
  let { Frame.responses } = Frame.method_info payload in
  let waiter, waker = wait () in
  channel_io.expected_responses <-
    channel_io.expected_responses @ [(responses, waker)];
  send_method_async channel_io payload >>
  waiter


(* Connection setup *)


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


let failwith_wrong_frame expected payload =
  failwith ("Expected " ^ expected ^ ", got: " ^ Frame.dump_payload payload)

let process_connection_start channel_io frame_payload =
  (* TODO: Assert channel 0 *)
  let body = match frame_payload with
    | Frame.Method (`Connection_start body) -> body
    | _ -> failwith_wrong_frame "Connection_start" frame_payload
  in
  let mechanism = choose_auth_mechanism body in
  let response = "\000guest\000guest" in
  let locale = choose_locale body in
  let frame_ok =
    Connection_start_ok.make_t ~client_properties ~mechanism ~response ~locale ()
  in
  send_method_async channel_io frame_ok
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
  (* Send connection.tune-ok *)
  let frame_ok =
    Connection_tune_ok.make_t ~channel_max ~frame_max ~heartbeat ()
  in
  send_method_async channel_io frame_ok
  (* Send connection.open *)
  >> let virtual_host = "/" in
  (* This is a sync method, but we're using an explicit state machine instead. *)
  send_method_async channel_io (Connection_open.make_t ~virtual_host ())
  >> return Connection_open


let process_connection_open channel_io frame_payload =
  (* TODO: Assert channel 0 *)
  let _ = match frame_payload with
    | Frame.Method (`Connection_open_ok body) -> body
    | _ -> failwith_wrong_frame "Connection_open_ok" frame_payload
  in
  Lwt_io.printlf "Connection open." >>
  return Connected


let process_setup_frame_payload channel_io frame_payload = function
  | Connection_start -> process_connection_start channel_io frame_payload
  | Connection_secure -> failwith "Unexpected Connection_secure state."
  | Connection_tune -> process_connection_tune channel_io frame_payload
  | Connection_open -> process_connection_open channel_io frame_payload
  | Connected -> assert false


let rec setup_connection connection state =
  let channel_io = Hashtbl.find connection.channels 0 in
  Lwt_stream.get channel_io.stream
  >>= function
  | None -> return ()
  | Some frame_payload -> process_setup_frame_payload channel_io frame_payload state
  >>= function
  | Connected -> set_connection_state connection Open; return ()
  | state -> setup_connection connection state


(* Misc *)


let next_channel channels =
  1 + Hashtbl.fold (fun k _ acc -> max k acc) channels 0


(* Stuff for outsiders *)


let connect ~server ?(port=5672) () =
  lwt connection_io = create_connection_io server port in
  let connection_send = write_frame connection_io in
  let channels = Hashtbl.create 10 in
  let _, finished = wait () in
  let connection =
    { connection_io; connection_send; channels; finished }
  in
  create_channel connection 0 Open;
  ignore_result (listen connection);
  setup_connection connection Connection_start >>
  return connection


let new_channel connection =
  let channel = next_channel connection.channels in
  create_channel connection channel Opening;
  let channel_io = Hashtbl.find connection.channels channel in
  send_method_sync channel_io (Channel_open.make_t ())
  >|= (fun _ -> channel_io.channel_state <- Open) >>
  return channel_io


let close_connection connection =
  set_connection_state connection Closing;
  let channel_io = Hashtbl.find connection.channels 0 in
  let close_method =
    Connection_close.make_t
      ~reply_code:200 ~reply_text:"Ok" ~class_id:0 ~method_id:0 ()
  in
  send_method_sync channel_io close_method
  >>= (fun _ ->
      set_connection_state connection Closed;
      let conn_io = connection.connection_io in
      Lwt_io.close conn_io.inch <&> Lwt_io.close conn_io.ouch)
