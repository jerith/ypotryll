open Lwt

open Ypotryll_methods


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
  log_section : Lwt_log.section;
  inch : Lwt_io.input_channel;
  ouch : Lwt_io.output_channel;
  mutable params : connection_params;
  connection_state : connection_state ref;
}


type expected_response =
  (int * int) list * Ypotryll_types.method_payload Lwt.u


type channel_io = {
  channel : int;
  stream : Frame.payload Lwt_stream.t;
  push : Frame.payload option -> unit;
  send : Frame.payload -> unit Lwt.t;
  mutable expected_responses : expected_response list;
  channel_state : connection_state ref;
}


type t = {
  connection_io : connection_io;
  connection_send : Frame.t -> unit Lwt.t;
  channels : (int, channel_io) Hashtbl.t;
  finished : unit Lwt.u;
}


type channel = {
  channel_io : channel_io;
  connection : t;
}


let default_params = {
  locale = "en_US";
  channel_max = 0;
  frame_max = 0;
  heartbeat = 0;
}


let log_debug connection_io =
  Lwt_log.debug_f ~section:connection_io.log_section

let log_info connection_io =
  Lwt_log.info_f ~section:connection_io.log_section


let debug_dump verb connection_io data =
  if false
  then
    Lwt_io.printlf "%s %d bytes:" verb (String.length data) >>
    Lwt_io.hexdump Lwt_io.stdout data
  else return_unit


let gethostbyname name =
  (* May raise Not_found from gethostbyname. *)
  Lwt_unix.gethostbyname name
  >>= fun entry ->
  return entry.Unix.h_addr_list.(0)


let write_data conn_io data =
  debug_dump "Sending" conn_io data >>
  Lwt_io.write conn_io.ouch data


let write_frame conn_io frame =
  write_data conn_io (Frame.build_frame frame)


let get_channel_io connection channel =
  Hashtbl.find connection.channels channel


let _set_state state_ref expected_state new_state =
  if !state_ref = expected_state
  then state_ref := new_state
  else failwith (
      "Can't transition to state " ^ (string_of_state new_state)
      ^ " from " ^ (string_of_state !state_ref) ^ ".")


let set_state state_ref = function
  | Opening -> failwith "Can't transition to state Opening."
  | Open -> _set_state state_ref Opening Open
  | Closing -> _set_state state_ref Open Closing
  | Closed -> _set_state state_ref Closing Closed


let create_connection_io server port log_section =
  lwt addr = gethostbyname server in
  Lwt_io.open_connection (Unix.ADDR_INET (addr, port))
  >>= fun (inch, ouch) ->
  let connection_state = ref Opening in
  let connection_io =
    { inch; ouch; params = default_params; connection_state; log_section }
  in
  write_data connection_io "AMQP\x00\x00\x09\x01" >>
  log_debug connection_io "\x1b[36m>>>\x1b[0m %S" "AMQP\x00\x00\x09\x01" >>
  return connection_io


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
  | Frame.Heartbeat -> failwith "Heartbeat frame on channel > 0."
  | Frame.Method payload ->
    process_channel_method channel_io payload; return_unit
  | frame_payload -> channel_io.push (Some frame_payload); return_unit


let kill_channel connection channel_io =
  Hashtbl.remove connection.channels channel_io.channel;
  channel_io.push None;
  let kill_expected (_, waker) =
    wakeup_exn waker (Failure "Channel closed.")
  in
  List.iter kill_expected channel_io.expected_responses


let kill_connection connection msg_opt =
  let sleeping = is_sleeping (waiter_of_wakener connection.finished) in
  let state = !(connection.connection_io.connection_state) in
  begin match sleeping, msg_opt, state with
    | false, _, _ -> ()
    | true, Some msg, _ -> wakeup_exn connection.finished (Failure msg)
    | true, None, Closed -> wakeup connection.finished ()
    | true, None, _ ->
      wakeup_exn connection.finished (Failure "Connection closed by peer.")
  end;
  let maybe_kill_channel channel channel_io =
    match channel with
    | 0 -> () (* Channel 0 is special. *)
    | _ -> kill_channel connection channel_io
  in
  Hashtbl.iter maybe_kill_channel connection.channels


let process_connection_close connection channel_io payload =
  let { Connection_close.reply_code; reply_text } = payload in
  set_state connection.connection_io.connection_state Closing;
  channel_io.send (Frame.Method (Connection_close_ok.make_t ()))
  >>= fun () ->
  set_state connection.connection_io.connection_state Closed;
  let conn_io = connection.connection_io in
  kill_connection connection
    (Some (Printf.sprintf "Connection error %d: %s" reply_code reply_text));
  Lwt_io.close conn_io.inch <&> Lwt_io.close conn_io.ouch


let process_channel_0_method connection channel_io = function
  | `Connection_close payload ->
    process_connection_close connection channel_io payload
  | payload -> process_channel_method channel_io payload; return_unit


let process_channel_0_frame connection channel_io = function
  | Frame.Heartbeat -> return_unit (* TODO: Heartbeat *)
  | Frame.Header _ | Frame.Body _ -> failwith "Content frame on channel 0."
  | Frame.Method payload ->
    process_channel_0_method connection channel_io payload


let process_frame connection channel payload =
    let channel_io = get_channel_io connection channel in
    log_debug connection.connection_io "\x1b[34m<<<[%d]\x1b[0m %s"
      channel_io.channel (Frame.dump_payload payload) >>
    match channel with
    | 0 -> process_channel_0_frame connection channel_io payload
    | _ -> process_channel_frame connection channel_io payload


let rec process_frames connection str =
  let frame, str = Frame.consume_frame str in
  match frame with
  | None -> return str
  | Some (channel, payload) ->
    process_frame connection channel payload >>
    process_frames connection str


let listen connection =
  let rec listen' buffer =
    (* Read some data into our string. *)
    begin
      try_lwt
        Lwt_io.read ~count:1024 connection.connection_io.inch
      with Lwt_io.Channel_closed _ -> return ""
    end
    >>= fun input ->
    debug_dump "Received" connection.connection_io input >>
    match String.length input with
    | 0 ->
      kill_connection connection None;
      log_info connection.connection_io "Connection closed."
    | _ ->
      Buffer.add_string buffer input;
      process_frames connection (Buffer.contents buffer)
      >>= fun remaining_data ->
      Buffer.reset buffer;
      Buffer.add_string buffer remaining_data;
      listen' buffer
  in
  listen' (Buffer.create 0)


let create_channel connection channel channel_state =
  let stream, push = Lwt_stream.create () in
  let send frame_payload =
    log_debug connection.connection_io "\x1b[36m>>>[%d]\x1b[0m %s"
      channel (Frame.dump_payload frame_payload) >>
    match Hashtbl.mem connection.channels channel with
    | false -> failwith "Channel closed."
    | true ->
      connection.connection_send (channel, frame_payload)
  in
  Hashtbl.add connection.channels channel
    { channel; stream; push; send; expected_responses = []; channel_state }


let send_method_async channel_io payload =
  channel_io.send (Frame.Method payload)


let send_content channel_io payload content =
  channel_io.send
    (Frame.Header (Int64.of_int (String.length content), payload)) >>
  (* TODO: Split big content frames. *)
  channel_io.send (Frame.Body content)


let send_method_sync channel_io payload =
  (* TODO: Figure out what to do with no-wait=true methods. *)
  let { Frame.responses } = Frame.method_info payload in
  let waiter, waker = wait () in
  channel_io.expected_responses <-
    channel_io.expected_responses @ [(responses, waker)];
  send_method_async channel_io payload >>
  waiter


(* Connection setup *)


let long_string value =
  Ypotryll_types.Table.Long_string value


let client_properties = [
  "copyright", long_string "Copyright (C) 2014 jerith";
  "information", long_string "Licensed under the MIT license.";
  "platform", long_string "OCaml";
  "product", long_string "ypotryll";
  "version", long_string "0.0.1";
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
    (String.sub str 0 pos,
     Some (String.sub str (pos + 1) ((String.length str) - pos - 1)))
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
  else failwith
      ("PLAIN not found in mechanisms: " ^ String.concat " " mechanisms)


let choose_locale body =
  let locales = split_string body.Connection_start.locales in
  if List.mem "en_US" locales
  then "en_US"
  else failwith ("en_US not found in locales: " ^ String.concat " " locales)


let failwith_wrong_frame expected payload =
  failwith ("Expected " ^ expected ^ ", got: " ^ Frame.dump_payload payload)

let process_connection_start channel_io frame_payload =
  let body = match frame_payload with
    | Frame.Method (`Connection_start body) -> body
    | _ -> failwith_wrong_frame "Connection_start" frame_payload
  in
  let mechanism = choose_auth_mechanism body in
  let response = "\000guest\000guest" in
  let locale = choose_locale body in
  let frame_ok =
    Connection_start_ok.make_t
      ~client_properties ~mechanism ~response ~locale ()
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
  (* This is a sync method, but we're using an explicit state machine. *)
  send_method_async channel_io (Connection_open.make_t ~virtual_host ())
  >> return Connection_open


let process_connection_open channel_io frame_payload =
  let _ = match frame_payload with
    | Frame.Method (`Connection_open_ok body) -> body
    | _ -> failwith_wrong_frame "Connection_open_ok" frame_payload
  in
  return Connected


let process_setup_frame_payload channel_io frame_payload = function
  | Connection_start -> process_connection_start channel_io frame_payload
  | Connection_secure -> failwith "Unexpected Connection_secure state."
  | Connection_tune -> process_connection_tune channel_io frame_payload
  | Connection_open -> process_connection_open channel_io frame_payload
  | Connected -> assert false


let rec setup_connection connection state =
  let channel_io = get_channel_io connection 0 in
  Lwt_stream.get channel_io.stream
  >>= function
  | None -> return_unit
  | Some frame_payload ->
    process_setup_frame_payload channel_io frame_payload state
  >>= function
  | Connected ->
    set_state connection.connection_io.connection_state Open;
    log_info connection.connection_io "Connection open."
  | state -> setup_connection connection state


(* Misc *)


let next_channel channels =
  1 + Hashtbl.fold (fun k _ acc -> max k acc) channels 0


(* Stuff for outsiders *)


let connect ~server ?(port=5672) ?log_section () =
  let log_section = match log_section with
    | None -> Lwt_log.Section.make "ypotryll"
    | Some log_section -> log_section
  in
  lwt connection_io = create_connection_io server port log_section in
  let connection_send = write_frame connection_io in
  let channels = Hashtbl.create 10 in
  let _, finished = wait () in
  let connection =
    { connection_io; connection_send; channels; finished }
  in
  create_channel connection 0 (ref Open);
  ignore_result (listen connection);
  setup_connection connection Connection_start >>
  return connection


let close_connection connection =
  set_state connection.connection_io.connection_state Closing;
  let channel_io = get_channel_io connection 0 in
  let close_method =
    Connection_close.make_t
      ~reply_code:200 ~reply_text:"Ok" ~class_id:0 ~method_id:0 ()
  in
  send_method_sync channel_io close_method
  >>= fun _ ->
  set_state connection.connection_io.connection_state Closed;
  let conn_io = connection.connection_io in
  Lwt_io.close conn_io.inch <&> Lwt_io.close conn_io.ouch


let new_channel connection =
  let channel = next_channel connection.channels in
  create_channel connection channel (ref Opening);
  let channel_io = get_channel_io connection channel in
  send_method_sync channel_io (Channel_open.make_t ())
  >|= (fun _ -> set_state channel_io.channel_state Open) >>
  return channel_io


let close_channel connection channel_io =
  set_state channel_io.channel_state Closing;
  let close_method =
    Channel_close.make_t
      ~reply_code:200 ~reply_text:"Ok" ~class_id:0 ~method_id:0 ()
  in
  send_method_sync channel_io close_method
  >|= fun _ ->
  set_state channel_io.channel_state Closed;
  kill_channel connection channel_io


let rec _collect_content_body channel_stream collected = function
  | 0L -> return (Some collected)
  | size ->
    Lwt_stream.peek channel_stream >>= function
    | None -> return_none
    | Some Frame.Heartbeat -> assert false
    | Some (Frame.Method _) -> return_none (* Methods interrupt content. *)
    | Some (Frame.Header _) ->
      failwith "Expected body frame, got header frame."
    | Some (Frame.Body content) ->
      Lwt_stream.junk channel_stream >>
      _collect_content_body channel_stream (collected ^ content)
        Int64.(sub size (of_int (String.length content)))

let _get_method_content channel_stream =
  Lwt_stream.get channel_stream >>= function
  | None -> return_none
  | Some Frame.Heartbeat -> assert false
  | Some (Frame.Method _) ->
    failwith "Expected header frame, got method frame."
  | Some (Frame.Body _) ->
    failwith "Expected header frame, got body frame."
  | Some (Frame.Header (size, payload)) ->
    _collect_content_body channel_stream "" size >>= function
    | None -> return_none
    | Some content -> return (Some (payload, content))


let get_method_with_content channel_stream =
  Lwt_stream.get channel_stream >>= function
  | None -> return_none
  | Some Frame.Heartbeat -> assert false
  | Some (Frame.Header _ | Frame.Body _) ->
    failwith "Expected method frame, got content frame."
  | Some (Frame.Method payload) ->
    match (Frame.method_info payload).Frame.content with
    | false -> return (Some (payload, None))
    | true ->
      _get_method_content channel_stream >>= function
      | None -> return_none
      | Some (properties, content) ->
        return (Some (payload, Some (properties, content)))
