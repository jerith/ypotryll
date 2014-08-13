(* This file is generated. See the code_gen dir for details. *)


module type Header = sig
  type t

  val name : string

  val class_id : int

  val parse_header : Parse_utils.Parse_buf.t -> Ypotryll_types.header_payload

  val build_header : int64 * Ypotryll_types.header_payload -> string

  val dump_header : int64 * Ypotryll_types.header_payload -> string
end


module Basic = struct
  open Protocol.Header_utils
  include Gen_basic.Basic

  type t = [`Basic of record]

  let buf_to_list = buf_to_list properties

  let string_of_list = string_of_list class_id

  let dump_list = dump_list name class_id

  let parse_header buf =
    `Basic (t_from_list (buf_to_list buf))

  let build_header = function
    | size, `Basic payload -> string_of_list size (t_to_list payload)
    | _ -> assert false

  let dump_header = function
    | size, `Basic payload -> dump_list size (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic payload -> t_to_list payload
    | _ -> assert false
end


let parse_header = function
  | 60 -> Basic.parse_header
  | class_id ->
    failwith (Printf.sprintf "Unknown content class: %d" class_id)


let module_for = function
  | `Basic _ -> (module Basic : Header)
