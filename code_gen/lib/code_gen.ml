
let generated_header =
  "(* This file is generated. See the code_gen dir for details. *)"

let gen_ml_filename name =
  let gen_dir = Filename.concat "lib" "gen" in
  Filename.concat gen_dir (name ^ ".ml")

let write_to_file filename data =
  let open Unix in
  let data = generated_header ^ "\n\n\n" ^ data in
  let fd = openfile filename [O_WRONLY; O_CREAT; O_TRUNC] 0o644 in
  let written = write fd data 0 (String.length data) in
  close fd;
  assert (written = String.length data)

let write_module_file method_module =
  let open Module_builder.Method_module in
  let filename = gen_ml_filename ("gen_" ^ method_module.name) in
  write_to_file filename method_module.text

let write_generated_methods_file spec =
  let filename = gen_ml_filename "generated_methods" in
  write_to_file filename (String.concat "\n\n\n" [
      Module_builder.build_method_module_type ();
      String.concat "\n\n\n" (Module_builder.build_method_wrappers spec);
      Module_builder.build_method_parsers spec;
      Module_builder.build_module_for_method spec;
    ])

let write_generated_types_file spec =
  let filename = gen_ml_filename "generated_method_types" in
  write_to_file filename (Module_builder.build_method_types spec ^ "\n")

let write_generated_frame_constants_file spec =
  let filename = gen_ml_filename "generated_frame_constants" in
  write_to_file filename (Module_builder.build_frame_constants spec)

let write_all_files channel =
  let spec = Spec_parser.parse_spec_from_channel channel in
  List.iter write_module_file (Module_builder.build_methods spec);
  write_generated_methods_file spec;
  write_generated_types_file spec;
  write_generated_frame_constants_file spec

let () = write_all_files stdin
