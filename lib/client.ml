
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
  sock: Lwt_unix.file_descr;
}

let rec really_write ~connection ~data ~offset ~length =
  if length = 0 then return () else
    Lwt_unix.write connection.sock data offset length
    >>= (fun chars_written ->
        really_write ~connection ~data
          ~offset:(offset + chars_written)
          ~length:(length - chars_written))

let write_data connection data =
  Lwt_io.printlf ">>> %S" data >>
  really_write ~connection ~data ~offset:0 ~length:(String.length data)

let connect ~addr ?(port=5672) () =
  open_socket addr port >>= (fun sock ->
      let connection = {sock = sock} in
      write_data connection "AMQP\x00\x00\x09\x01"
      >>= (fun () -> return connection))

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


let process_start_frame frame =
  (* TODO: Assert channel 0 *)
  let body = match Frame.extract_method frame.Frame.payload with
    | `Connection_start body -> body
    | _ -> failwith ("Expected Connection_start, got: " ^ Frame.frame_to_string frame)
  in
  let mechanism = choose_auth_mechanism body in
  let locale = choose_locale body in
  Lwt_io.printlf "<<< START %s" (Frame.frame_to_string frame)
  >> Lwt_io.printlf "Auth mechanism: %S" mechanism
  >> Lwt_io.printlf "Locales: %S" locale
  >> return Connected


let vomit_frame frame state =
  Lwt_io.printlf "<<< %s" (Frame.frame_to_string frame)
  >> return state


let process_frame callback frame = function
  | Connection_start -> process_start_frame frame
  | Connection_start_challenge -> failwith "Unexpected Connection_start_challenge state."
  | Connection_tune -> vomit_frame frame Connection_open
  | Connection_open -> vomit_frame frame Connected
  | Connected -> callback frame >> return Connected


let rec process_frames callback str state =
  (* TODO: Avoid waiting here. *)
  let frame, str = Frame.consume_frame str in
  match frame with
  | None -> return (str, state)
  | Some frame -> begin
      process_frame callback frame state
      >>= process_frames callback str
    end


let listen connection callback =
  let read_length = 1024 in
  let read_data = String.create read_length in
  let rec listen' ~state ~buffer =
    (* Read some data into our string. *)
    Lwt_unix.read connection.sock read_data 0 read_length
    >>= (fun chars_read ->
        if chars_read = 0 (* EOF from server - we have quit or been kicked. *)
        then return state
        else begin
          let input = String.sub read_data 0 chars_read in
          Buffer.add_string buffer input;
          process_frames callback (Buffer.contents buffer) state
          >>= (fun (remaining_data, state) ->
              Buffer.reset buffer;
              Buffer.add_string buffer remaining_data;
              return state)
        end)
    >>= (fun state -> listen' ~state ~buffer)
  in
  let buffer = Buffer.create 0 in
  listen' ~state:Connection_start ~buffer
