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
}


type t = {
  connection_io : connection_io;
  (* stream : Frame.t Lwt_stream.t; *)
  (* push : Frame.t option -> unit; *)
  mutable params : connection_params;
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


let connect ~server ?(port=5672) () =
  lwt addr = gethostbyname server in
  Lwt_io.open_connection (Unix.ADDR_INET (addr, port))
  >>= (fun (inch, ouch) ->
      let connection_io = { inch; ouch } in
      let connection = { connection_io; params = default_params } in
      write_data connection_io "AMQP\x00\x00\x09\x01" >>
      return connection)
