open Lwt

type connection_params = {
  locale : string;
  channel_max : int;
  frame_max : int;
  heartbeat : int;
}

type t = {
  inch : Lwt_io.input_channel;
  ouch : Lwt_io.output_channel;
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

let write_data conn data =
  Printf.printf ">>> %S\n%!" data;
  Lwt_io.write conn.ouch data

let connect ~server ?(port=5672) () =
  lwt addr = gethostbyname server in
  Lwt_io.open_connection (Unix.ADDR_INET (addr, port))
  >>= (fun (inch, ouch) ->
      let conn = { inch; ouch; params = default_params } in
      return conn)
