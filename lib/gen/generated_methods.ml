
module Connection_start = struct
  include Gen_connection_start.Connection_start

  type t = [`Connection_start of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments
  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Connection_start (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Connection_start payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_start payload -> t_to_list payload
    | _ -> assert false

end


let build_method_instance = function
  | (10, 10) -> (Stubs.build_payload (module Connection_start))
  | (class_id, method_id) -> failwith (Printf.sprintf "Unknown method: (%d, %d)" class_id method_id)
