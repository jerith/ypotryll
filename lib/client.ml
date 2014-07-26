
open Lwt

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



let rec process_frames str callback =
  (* TODO: Avoid waiting here. *)
  let frame, str = Frame.consume_frame str in
  match frame with
  | None -> return str
  | Some frame ->
    callback frame
    >> process_frames str callback


let listen connection callback =
  let read_length = 1024 in
  let read_data = String.create read_length in
  let rec listen' ~buffer =
    (* Read some data into our string. *)
    Lwt_unix.read connection.sock read_data 0 read_length
    >>= (fun chars_read ->
      if chars_read = 0 (* EOF from server - we have quit or been kicked. *)
      then return ()
      else begin
        let input = String.sub read_data 0 chars_read in
        Buffer.add_string buffer input;
        process_frames (Buffer.contents buffer) callback
        >>= (fun remaining_data ->
            Buffer.reset buffer;
            Buffer.add_string buffer remaining_data;
            return ())
      end)
    >>= (fun () -> listen' ~buffer)
  in
  let buffer = Buffer.create 0 in
  listen' ~buffer
