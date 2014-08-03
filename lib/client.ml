
open Lwt

open Generated_methods


(* IO stuff *)
let open_socket addr port =
  let sock = Lwt_unix.socket Lwt_unix.PF_INET Lwt_unix.SOCK_STREAM 0 in
  let sockaddr = Lwt_unix.ADDR_INET (addr, port) in
  lwt () = Lwt_unix.connect sock sockaddr in
  return sock

let gethostbyname name =
  try_lwt
    lwt entry = Lwt_unix.gethostbyname name in
    let addrs = Array.to_list entry.Unix.h_addr_list in
    Lwt.return addrs
  with Not_found ->
    Lwt.return_nil


(* Client stuff *)
type connection_t = {
  inch : Lwt_io.input_channel;
  ouch : Lwt_io.output_channel;
}

let write_data connection data =
  Printf.printf ">>> %S\n%!" data;
  Lwt_io.write connection.ouch data

let connect ~addr ?(port=5672) () =
  Lwt_io.open_connection (Unix.ADDR_INET (addr, port))
  >>= (fun (inch, ouch) ->
      let connection = { inch; ouch } in
      write_data connection "AMQP\x00\x00\x09\x01"
      >> return connection)

let connect_by_name ~server ?port () =
  gethostbyname server
  >>= (function
      | [] -> return None
      | addr :: _ ->
        connect ~addr ?port ()
        >>= (fun connection -> return (Some connection)))


type protocol_state =
  | Connection_start
  | Connection_start_challenge (* Not used currently. *)
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


let process_start_frame connection frame =
  (* TODO: Assert channel 0 *)
  let body = match Frame.extract_method frame.Frame.payload with
    | `Connection_start body -> body
    | _ -> failwith ("Expected Connection_start, got: " ^ Frame.frame_to_string frame)
  in
  let mechanism = choose_auth_mechanism body in
  let response = "\000guest\000guest" in
  let locale = choose_locale body in
  Printf.printf "<<< START %s\n%!" (Frame.frame_to_string frame);
  Printf.printf "Auth mechanism: %S\n%!" mechanism;
  Printf.printf "Locales: %S\n%!" locale;
  begin
    let frame_ok_str = Frame.emit_method_frame 0 (`Connection_start_ok {
        Connection_start_ok.client_properties = [
          "copyright", Protocol.Amqp_table.Long_string "Copyright (C) 2014 jerith";
          "information", Protocol.Amqp_table.Long_string "Licensed under the MIT license.";
          "platform", Protocol.Amqp_table.Long_string "OCaml";
          "product", Protocol.Amqp_table.Long_string "ypotryll";
          "version", Protocol.Amqp_table.Long_string "0.0.1";
        ];
        Connection_start_ok.mechanism;
        Connection_start_ok.response;
        Connection_start_ok.locale;
      })
    in
    write_data connection frame_ok_str
  end
  >> return Connected


let vomit_frame frame state =
  Printf.printf "<<< %s\n%!" (Frame.frame_to_string frame);
  return state


let process_frame connection callback frame = function
  | Connection_start -> process_start_frame connection frame
  | Connection_start_challenge -> failwith "Unexpected Connection_start_challenge state."
  | Connection_tune -> vomit_frame frame Connection_open
  | Connection_open -> vomit_frame frame Connected
  | Connected -> callback frame >> return Connected
  | Disconnected -> failwith "Disconnected."


let rec process_frames connection callback str state =
  (* TODO: Avoid waiting here. *)
  let frame, str = Frame.consume_frame str in
  match frame with
  | None -> return (str, state)
  | Some frame -> begin
      process_frame connection callback frame state
      >>= process_frames connection callback str
    end


let listen connection callback =
  let rec listen' ~state ~buffer =
    (* Read some data into our string. *)
    Lwt_io.read ~count:1024 connection.inch
    >>= (fun input ->
        Lwt_io.printlf "Read bytes: %d" (String.length input) >>
        if String.length input = 0 (* EOF from server - we have quit or been kicked. *)
        then return Disconnected
        else begin
          Buffer.add_string buffer input;
          process_frames connection callback (Buffer.contents buffer) state
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
