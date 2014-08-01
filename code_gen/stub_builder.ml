
let stub_text = "
module type Method = sig
  type t

  val parse_method : Parse_utils.Parse_buf.t -> Generated_method_types.method_payload
  val build_method : Generated_method_types.method_payload -> string

  (* temporary? *)
  val buf_to_list : Parse_utils.Parse_buf.t -> (string * Protocol.Amqp_field.t) list
  val string_of_list : (string * Protocol.Amqp_field.t) list -> string

  val list_of_t : Generated_method_types.method_payload -> (string * Protocol.Amqp_field.t) list
end


module type Method_instance = sig
  module Method : Method
  val this : Generated_method_types.method_payload
end


let build_payload (module P : Method) buf =
  (module struct
     module Method = P
     let this = P.parse_method buf
   end : Method_instance)
"

let build_stubs () =
  stub_text
