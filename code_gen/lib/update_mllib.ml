
open Lwt


let str_starts_with prefix str =
  let str_len = String.length str in
  let prefix_len = String.length prefix in
  str_len >= prefix_len
  && String.sub str 0 prefix_len = prefix


let str_ends_with suffix str =
  let str_len = String.length str in
  let suffix_len = String.length suffix in
  str_len >= suffix_len
  && String.sub str (str_len - suffix_len) suffix_len = suffix


let modname_of_filename filename =
  String.capitalize (String.sub filename 0 (String.length filename - 3))


let get_modules () =
  let process_filename line =
    if str_starts_with "gen_" line && str_ends_with ".ml" line
    then Some ("gen/" ^ modname_of_filename line)
    else None
  in
  let gen_dir = Filename.concat "lib" "gen" in
  let filenames = Lwt_unix.files_of_directory gen_dir in
  Lwt_stream.to_list (Lwt_stream.filter_map process_filename filenames)
  >|= List.sort String.compare


type file_state =
  | Header
  | Body
  | Footer


let update_content modules inst =
  let oust, push = Lwt_stream.create () in
  let rec process_lines state =
    Lwt_stream.get inst >>= fun line_opt ->
    match state with
    | Header -> process_header_line line_opt
    | Body -> process_body_line line_opt
    | Footer -> process_footer_line line_opt
  and process_header_line = function
    | None -> failwith "No replace section start token found."
    | Some "# YPOTRYLL_GEN_START" as line -> push line; process_lines Body
    | Some _ as line -> push line; process_lines Header
  and process_body_line = function
    | None -> failwith "No replace section end token found."
    | Some "# YPOTRYLL_GEN_STOP" as line ->
      List.iter (fun x -> push (Some x)) modules;
      push line;
      process_lines Footer
    | Some _ -> process_lines Body
  and process_footer_line = function
    | None -> push None; return oust
    | Some _ as line -> push line; process_lines Footer
  in
  process_lines Header


let write_lines_to_file filename lines =
  let write_to_file ouch =
    join (List.map (fun line -> Lwt_io.write ouch (line ^ "\n")) lines)
  in
  Lwt_io.with_file ~mode:Lwt_io.output filename write_to_file


let update_file modules filename =
  return (Lwt_io.lines_of_file filename)
  >>= update_content modules
  >>= Lwt_stream.to_list (* To consume all input before overwriting file. *)
  >>= write_lines_to_file filename


let lwt_main () =
  get_modules ()
  >>= fun modules ->
  update_file modules "lib/ypotryll.mllib" >>
  update_file modules "lib/ypotryll.mldylib"


let () = Lwt_main.run (lwt_main ())
