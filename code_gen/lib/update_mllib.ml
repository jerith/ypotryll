
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


type file_state =
  | Header
  | Body
  | Footer


let update_content modules inch =
  let inst = Lwt_io.read_lines inch in
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


let update_file modules filename =
  let write_lines lines ch = Lwt_io.write_lines ch lines in
  Lwt_io.with_file ~mode:Lwt_io.input filename (update_content modules)
  >>= fun lines ->
  Lwt_io.with_file ~mode:Lwt_io.output filename (write_lines lines)


let lwt_main () =
  get_modules ()
  >>= fun modules ->
  update_file modules "lib/ypotryll.mllib" >>
  update_file modules "lib/ypotryll.mldylib"


let () = Lwt_main.run (lwt_main ())


(* let build_updated_content inch = *)


(* let generated_header = *)
(*   "(\* This file is generated. See the code_gen dir for details. *\)" *)

(* let gen_ml_filename name = *)
(*   let gen_dir = Filename.concat "lib" "gen" in *)
(*   Filename.concat gen_dir (name ^ ".ml") *)

(* let write_to_file filename data = *)
(*   let open Unix in *)
(*   let data = generated_header ^ "\n\n\n" ^ data in *)
(*   let fd = openfile filename [O_WRONLY; O_CREAT; O_TRUNC] 0o644 in *)
(*   let written = write fd data 0 (String.length data) in *)
(*   close fd; *)
(*   assert (written = String.length data) *)

(* let write_module_file method_module = *)
(*   let open Module_builder.Method_module in *)
(*   let filename = gen_ml_filename ("gen_" ^ method_module.name) in *)
(*   write_to_file filename method_module.text *)

(* let write_generated_methods_file spec = *)
(*   let filename = gen_ml_filename "ypotryll_methods" in *)
(*   write_to_file filename (String.concat "\n\n\n" [ *)
(*       Module_builder.build_method_module_type (); *)
(*       String.concat "\n\n\n" (Module_builder.build_method_wrappers spec); *)
(*       Module_builder.build_method_parsers spec; *)
(*       Module_builder.build_module_for_method spec; *)
(*     ]) *)

(* let write_generated_types_file spec = *)
(*   let filename = gen_ml_filename "generated_method_types" in *)
(*   write_to_file filename (Module_builder.build_method_types spec ^ "\n") *)

(* let write_generated_frame_constants_file spec = *)
(*   let filename = gen_ml_filename "generated_frame_constants" in *)
(*   write_to_file filename (Module_builder.build_frame_constants spec) *)

(* let write_all_files channel = *)
(*   let spec = Spec_parser.parse_spec_from_channel channel in *)
(*   List.iter write_module_file (Module_builder.build_methods spec); *)
(*   write_generated_methods_file spec; *)
(*   write_generated_types_file spec; *)
(*   write_generated_frame_constants_file spec *)

(* let () = write_all_files stdin *)
