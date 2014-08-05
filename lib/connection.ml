open Lwt

type connection_params = {
  locale : string;
  channel_max : int;
  frame_max : int;
  heartbeat : int;
}


type connection_io = {
  inch : Lwt_io.input_channel;
  ouch : Lwt_io.output_channel;
  mutable params : connection_params;
}


type t = {
  connection_io : connection_io;
  stream : Frame.t Lwt_stream.t;
  send : Frame.t -> unit Lwt.t;
  listener : unit Lwt.t;
}


let default_params = {
  locale = "en_US";
  channel_max = 0;
  frame_max = 0;
  heartbeat = 0;
}


let gethostbyname name =
  (* May raise Not_found from gethostbyname. *)
  Lwt_unix.gethostbyname name
  >>= (fun entry -> return entry.Unix.h_addr_list.(0))

let write_data conn_io data =
  Printf.printf ">>> %S\n%!" data;
  Lwt_io.write conn_io.ouch data


let write_frame conn_io frame =
  write_data conn_io (Frame.build_frame frame)


let create_connection_io server port =
  lwt addr = gethostbyname server in
  Lwt_io.open_connection (Unix.ADDR_INET (addr, port))
  >>= (fun (inch, ouch) ->
      let connection_io = { inch; ouch; params = default_params } in
      write_data connection_io "AMQP\x00\x00\x09\x01" >>
      return connection_io)


let rec process_frames push str =
  let frame, str = Frame.consume_frame str in
  match frame with
  | None -> return str
  | Some frame -> push (Some frame); process_frames push str


let listen conn_io push =
  let rec listen' buffer =
    (* Read some data into our string. *)
    Lwt_io.read ~count:1024 conn_io.inch
    >>= (fun input ->
        Lwt_io.printlf "Read bytes: %d" (String.length input) >>
        Lwt_io.hexdump Lwt_io.stdout input >>
        Lwt_io.flush Lwt_io.stdout >>
        if String.length input = 0 (* EOF from server - we have quit or been kicked. *)
        then begin
          push None;
          return ()
        end else begin
          Buffer.add_string buffer input;
          process_frames push (Buffer.contents buffer)
          >>= (fun remaining_data ->
              Buffer.reset buffer;
              Buffer.add_string buffer remaining_data;
              listen' buffer)
        end)
  in
  listen' (Buffer.create 0)


let connect ~server ?(port=5672) () =
  lwt connection_io = create_connection_io server port in
  let stream, push = Lwt_stream.create () in
  let listener = listen connection_io push in
  let send = write_frame connection_io in
  let connection = { connection_io; stream; send; listener } in
  return connection
