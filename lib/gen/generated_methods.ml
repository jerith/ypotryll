(* This file is generated. See the code_gen dir for details. *)


module type Method = sig
  type t
  open Generated_method_types

  val name : string

  val class_id : int

  val method_id : int

  val synchronous : bool

  val responses : (int * int) list

  val parse_method : Parse_utils.Parse_buf.t -> method_payload

  val build_method : method_payload -> string

  val dump_method : method_payload -> string
end


module Connection_start = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_connection_start.Connection_start

  type t = [`Connection_start of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Connection_start (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Connection_start payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Connection_start payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_start payload -> t_to_list payload
    | _ -> assert false
end


module Connection_start_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_connection_start_ok.Connection_start_ok

  type t = [`Connection_start_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Connection_start_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Connection_start_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Connection_start_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_start_ok payload -> t_to_list payload
    | _ -> assert false
end


module Connection_secure = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_connection_secure.Connection_secure

  type t = [`Connection_secure of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Connection_secure (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Connection_secure payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Connection_secure payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_secure payload -> t_to_list payload
    | _ -> assert false
end


module Connection_secure_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_connection_secure_ok.Connection_secure_ok

  type t = [`Connection_secure_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Connection_secure_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Connection_secure_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Connection_secure_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_secure_ok payload -> t_to_list payload
    | _ -> assert false
end


module Connection_tune = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_connection_tune.Connection_tune

  type t = [`Connection_tune of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Connection_tune (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Connection_tune payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Connection_tune payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_tune payload -> t_to_list payload
    | _ -> assert false
end


module Connection_tune_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_connection_tune_ok.Connection_tune_ok

  type t = [`Connection_tune_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Connection_tune_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Connection_tune_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Connection_tune_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_tune_ok payload -> t_to_list payload
    | _ -> assert false
end


module Connection_open = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_connection_open.Connection_open

  type t = [`Connection_open of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Connection_open (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Connection_open payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Connection_open payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_open payload -> t_to_list payload
    | _ -> assert false
end


module Connection_open_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_connection_open_ok.Connection_open_ok

  type t = [`Connection_open_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Connection_open_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Connection_open_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Connection_open_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_open_ok payload -> t_to_list payload
    | _ -> assert false
end


module Connection_close = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_connection_close.Connection_close

  type t = [`Connection_close of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Connection_close (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Connection_close payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Connection_close payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_close payload -> t_to_list payload
    | _ -> assert false
end


module Connection_close_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_connection_close_ok.Connection_close_ok

  type t = [`Connection_close_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Connection_close_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Connection_close_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Connection_close_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_close_ok payload -> t_to_list payload
    | _ -> assert false
end


module Channel_open = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_channel_open.Channel_open

  type t = [`Channel_open of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Channel_open (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Channel_open payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Channel_open payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_open payload -> t_to_list payload
    | _ -> assert false
end


module Channel_open_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_channel_open_ok.Channel_open_ok

  type t = [`Channel_open_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Channel_open_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Channel_open_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Channel_open_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_open_ok payload -> t_to_list payload
    | _ -> assert false
end


module Channel_flow = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_channel_flow.Channel_flow

  type t = [`Channel_flow of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Channel_flow (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Channel_flow payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Channel_flow payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_flow payload -> t_to_list payload
    | _ -> assert false
end


module Channel_flow_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_channel_flow_ok.Channel_flow_ok

  type t = [`Channel_flow_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Channel_flow_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Channel_flow_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Channel_flow_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_flow_ok payload -> t_to_list payload
    | _ -> assert false
end


module Channel_close = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_channel_close.Channel_close

  type t = [`Channel_close of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Channel_close (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Channel_close payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Channel_close payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_close payload -> t_to_list payload
    | _ -> assert false
end


module Channel_close_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_channel_close_ok.Channel_close_ok

  type t = [`Channel_close_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Channel_close_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Channel_close_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Channel_close_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_close_ok payload -> t_to_list payload
    | _ -> assert false
end


module Exchange_declare = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_exchange_declare.Exchange_declare

  type t = [`Exchange_declare of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Exchange_declare (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Exchange_declare payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Exchange_declare payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Exchange_declare payload -> t_to_list payload
    | _ -> assert false
end


module Exchange_declare_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_exchange_declare_ok.Exchange_declare_ok

  type t = [`Exchange_declare_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Exchange_declare_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Exchange_declare_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Exchange_declare_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Exchange_declare_ok payload -> t_to_list payload
    | _ -> assert false
end


module Exchange_delete = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_exchange_delete.Exchange_delete

  type t = [`Exchange_delete of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Exchange_delete (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Exchange_delete payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Exchange_delete payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Exchange_delete payload -> t_to_list payload
    | _ -> assert false
end


module Exchange_delete_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_exchange_delete_ok.Exchange_delete_ok

  type t = [`Exchange_delete_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Exchange_delete_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Exchange_delete_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Exchange_delete_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Exchange_delete_ok payload -> t_to_list payload
    | _ -> assert false
end


module Queue_declare = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_queue_declare.Queue_declare

  type t = [`Queue_declare of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Queue_declare (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Queue_declare payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Queue_declare payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_declare payload -> t_to_list payload
    | _ -> assert false
end


module Queue_declare_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_queue_declare_ok.Queue_declare_ok

  type t = [`Queue_declare_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Queue_declare_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Queue_declare_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Queue_declare_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_declare_ok payload -> t_to_list payload
    | _ -> assert false
end


module Queue_bind = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_queue_bind.Queue_bind

  type t = [`Queue_bind of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Queue_bind (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Queue_bind payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Queue_bind payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_bind payload -> t_to_list payload
    | _ -> assert false
end


module Queue_bind_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_queue_bind_ok.Queue_bind_ok

  type t = [`Queue_bind_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Queue_bind_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Queue_bind_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Queue_bind_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_bind_ok payload -> t_to_list payload
    | _ -> assert false
end


module Queue_unbind = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_queue_unbind.Queue_unbind

  type t = [`Queue_unbind of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Queue_unbind (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Queue_unbind payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Queue_unbind payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_unbind payload -> t_to_list payload
    | _ -> assert false
end


module Queue_unbind_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_queue_unbind_ok.Queue_unbind_ok

  type t = [`Queue_unbind_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Queue_unbind_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Queue_unbind_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Queue_unbind_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_unbind_ok payload -> t_to_list payload
    | _ -> assert false
end


module Queue_purge = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_queue_purge.Queue_purge

  type t = [`Queue_purge of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Queue_purge (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Queue_purge payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Queue_purge payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_purge payload -> t_to_list payload
    | _ -> assert false
end


module Queue_purge_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_queue_purge_ok.Queue_purge_ok

  type t = [`Queue_purge_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Queue_purge_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Queue_purge_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Queue_purge_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_purge_ok payload -> t_to_list payload
    | _ -> assert false
end


module Queue_delete = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_queue_delete.Queue_delete

  type t = [`Queue_delete of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Queue_delete (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Queue_delete payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Queue_delete payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_delete payload -> t_to_list payload
    | _ -> assert false
end


module Queue_delete_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_queue_delete_ok.Queue_delete_ok

  type t = [`Queue_delete_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Queue_delete_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Queue_delete_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Queue_delete_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_delete_ok payload -> t_to_list payload
    | _ -> assert false
end


module Basic_qos = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_qos.Basic_qos

  type t = [`Basic_qos of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_qos (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_qos payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_qos payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_qos payload -> t_to_list payload
    | _ -> assert false
end


module Basic_qos_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_qos_ok.Basic_qos_ok

  type t = [`Basic_qos_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_qos_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_qos_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_qos_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_qos_ok payload -> t_to_list payload
    | _ -> assert false
end


module Basic_consume = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_consume.Basic_consume

  type t = [`Basic_consume of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_consume (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_consume payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_consume payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_consume payload -> t_to_list payload
    | _ -> assert false
end


module Basic_consume_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_consume_ok.Basic_consume_ok

  type t = [`Basic_consume_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_consume_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_consume_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_consume_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_consume_ok payload -> t_to_list payload
    | _ -> assert false
end


module Basic_cancel = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_cancel.Basic_cancel

  type t = [`Basic_cancel of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_cancel (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_cancel payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_cancel payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_cancel payload -> t_to_list payload
    | _ -> assert false
end


module Basic_cancel_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_cancel_ok.Basic_cancel_ok

  type t = [`Basic_cancel_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_cancel_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_cancel_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_cancel_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_cancel_ok payload -> t_to_list payload
    | _ -> assert false
end


module Basic_publish = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_publish.Basic_publish

  type t = [`Basic_publish of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_publish (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_publish payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_publish payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_publish payload -> t_to_list payload
    | _ -> assert false
end


module Basic_return = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_return.Basic_return

  type t = [`Basic_return of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_return (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_return payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_return payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_return payload -> t_to_list payload
    | _ -> assert false
end


module Basic_deliver = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_deliver.Basic_deliver

  type t = [`Basic_deliver of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_deliver (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_deliver payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_deliver payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_deliver payload -> t_to_list payload
    | _ -> assert false
end


module Basic_get = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_get.Basic_get

  type t = [`Basic_get of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_get (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_get payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_get payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_get payload -> t_to_list payload
    | _ -> assert false
end


module Basic_get_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_get_ok.Basic_get_ok

  type t = [`Basic_get_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_get_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_get_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_get_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_get_ok payload -> t_to_list payload
    | _ -> assert false
end


module Basic_get_empty = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_get_empty.Basic_get_empty

  type t = [`Basic_get_empty of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_get_empty (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_get_empty payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_get_empty payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_get_empty payload -> t_to_list payload
    | _ -> assert false
end


module Basic_ack = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_ack.Basic_ack

  type t = [`Basic_ack of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_ack (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_ack payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_ack payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_ack payload -> t_to_list payload
    | _ -> assert false
end


module Basic_reject = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_reject.Basic_reject

  type t = [`Basic_reject of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_reject (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_reject payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_reject payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_reject payload -> t_to_list payload
    | _ -> assert false
end


module Basic_recover_async = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_recover_async.Basic_recover_async

  type t = [`Basic_recover_async of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_recover_async (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_recover_async payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_recover_async payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_recover_async payload -> t_to_list payload
    | _ -> assert false
end


module Basic_recover = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_recover.Basic_recover

  type t = [`Basic_recover of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_recover (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_recover payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_recover payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_recover payload -> t_to_list payload
    | _ -> assert false
end


module Basic_recover_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_basic_recover_ok.Basic_recover_ok

  type t = [`Basic_recover_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Basic_recover_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Basic_recover_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Basic_recover_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_recover_ok payload -> t_to_list payload
    | _ -> assert false
end


module Tx_select = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_tx_select.Tx_select

  type t = [`Tx_select of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Tx_select (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Tx_select payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Tx_select payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_select payload -> t_to_list payload
    | _ -> assert false
end


module Tx_select_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_tx_select_ok.Tx_select_ok

  type t = [`Tx_select_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Tx_select_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Tx_select_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Tx_select_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_select_ok payload -> t_to_list payload
    | _ -> assert false
end


module Tx_commit = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_tx_commit.Tx_commit

  type t = [`Tx_commit of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Tx_commit (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Tx_commit payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Tx_commit payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_commit payload -> t_to_list payload
    | _ -> assert false
end


module Tx_commit_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_tx_commit_ok.Tx_commit_ok

  type t = [`Tx_commit_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Tx_commit_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Tx_commit_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Tx_commit_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_commit_ok payload -> t_to_list payload
    | _ -> assert false
end


module Tx_rollback = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_tx_rollback.Tx_rollback

  type t = [`Tx_rollback of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Tx_rollback (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Tx_rollback payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Tx_rollback payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_rollback payload -> t_to_list payload
    | _ -> assert false
end


module Tx_rollback_ok = struct
  open Generated_method_types
  open Protocol.Method_utils
  include Gen_tx_rollback_ok.Tx_rollback_ok

  type t = [`Tx_rollback_ok of record]

  let buf_to_list = buf_to_list arguments

  let string_of_list = string_of_list class_id method_id

  let dump_list = dump_list name class_id method_id

  let parse_method buf =
    (`Tx_rollback_ok (t_from_list (buf_to_list buf)) :> method_payload)

  let build_method = function
    | `Tx_rollback_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let dump_method = function
    | `Tx_rollback_ok payload -> dump_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_rollback_ok payload -> t_to_list payload
    | _ -> assert false
end


let parse_method = function
  | (10, 10) -> Connection_start.parse_method
  | (10, 11) -> Connection_start_ok.parse_method
  | (10, 20) -> Connection_secure.parse_method
  | (10, 21) -> Connection_secure_ok.parse_method
  | (10, 30) -> Connection_tune.parse_method
  | (10, 31) -> Connection_tune_ok.parse_method
  | (10, 40) -> Connection_open.parse_method
  | (10, 41) -> Connection_open_ok.parse_method
  | (10, 50) -> Connection_close.parse_method
  | (10, 51) -> Connection_close_ok.parse_method
  | (20, 10) -> Channel_open.parse_method
  | (20, 11) -> Channel_open_ok.parse_method
  | (20, 20) -> Channel_flow.parse_method
  | (20, 21) -> Channel_flow_ok.parse_method
  | (20, 40) -> Channel_close.parse_method
  | (20, 41) -> Channel_close_ok.parse_method
  | (40, 10) -> Exchange_declare.parse_method
  | (40, 11) -> Exchange_declare_ok.parse_method
  | (40, 20) -> Exchange_delete.parse_method
  | (40, 21) -> Exchange_delete_ok.parse_method
  | (50, 10) -> Queue_declare.parse_method
  | (50, 11) -> Queue_declare_ok.parse_method
  | (50, 20) -> Queue_bind.parse_method
  | (50, 21) -> Queue_bind_ok.parse_method
  | (50, 50) -> Queue_unbind.parse_method
  | (50, 51) -> Queue_unbind_ok.parse_method
  | (50, 30) -> Queue_purge.parse_method
  | (50, 31) -> Queue_purge_ok.parse_method
  | (50, 40) -> Queue_delete.parse_method
  | (50, 41) -> Queue_delete_ok.parse_method
  | (60, 10) -> Basic_qos.parse_method
  | (60, 11) -> Basic_qos_ok.parse_method
  | (60, 20) -> Basic_consume.parse_method
  | (60, 21) -> Basic_consume_ok.parse_method
  | (60, 30) -> Basic_cancel.parse_method
  | (60, 31) -> Basic_cancel_ok.parse_method
  | (60, 40) -> Basic_publish.parse_method
  | (60, 50) -> Basic_return.parse_method
  | (60, 60) -> Basic_deliver.parse_method
  | (60, 70) -> Basic_get.parse_method
  | (60, 71) -> Basic_get_ok.parse_method
  | (60, 72) -> Basic_get_empty.parse_method
  | (60, 80) -> Basic_ack.parse_method
  | (60, 90) -> Basic_reject.parse_method
  | (60, 100) -> Basic_recover_async.parse_method
  | (60, 110) -> Basic_recover.parse_method
  | (60, 111) -> Basic_recover_ok.parse_method
  | (90, 10) -> Tx_select.parse_method
  | (90, 11) -> Tx_select_ok.parse_method
  | (90, 20) -> Tx_commit.parse_method
  | (90, 21) -> Tx_commit_ok.parse_method
  | (90, 30) -> Tx_rollback.parse_method
  | (90, 31) -> Tx_rollback_ok.parse_method
  | (class_id, method_id) ->
    failwith (Printf.sprintf "Unknown method: (%d, %d)" class_id method_id)


let module_for = function
  | `Connection_start _ -> (module Connection_start : Method)
  | `Connection_start_ok _ -> (module Connection_start_ok : Method)
  | `Connection_secure _ -> (module Connection_secure : Method)
  | `Connection_secure_ok _ -> (module Connection_secure_ok : Method)
  | `Connection_tune _ -> (module Connection_tune : Method)
  | `Connection_tune_ok _ -> (module Connection_tune_ok : Method)
  | `Connection_open _ -> (module Connection_open : Method)
  | `Connection_open_ok _ -> (module Connection_open_ok : Method)
  | `Connection_close _ -> (module Connection_close : Method)
  | `Connection_close_ok _ -> (module Connection_close_ok : Method)
  | `Channel_open _ -> (module Channel_open : Method)
  | `Channel_open_ok _ -> (module Channel_open_ok : Method)
  | `Channel_flow _ -> (module Channel_flow : Method)
  | `Channel_flow_ok _ -> (module Channel_flow_ok : Method)
  | `Channel_close _ -> (module Channel_close : Method)
  | `Channel_close_ok _ -> (module Channel_close_ok : Method)
  | `Exchange_declare _ -> (module Exchange_declare : Method)
  | `Exchange_declare_ok _ -> (module Exchange_declare_ok : Method)
  | `Exchange_delete _ -> (module Exchange_delete : Method)
  | `Exchange_delete_ok _ -> (module Exchange_delete_ok : Method)
  | `Queue_declare _ -> (module Queue_declare : Method)
  | `Queue_declare_ok _ -> (module Queue_declare_ok : Method)
  | `Queue_bind _ -> (module Queue_bind : Method)
  | `Queue_bind_ok _ -> (module Queue_bind_ok : Method)
  | `Queue_unbind _ -> (module Queue_unbind : Method)
  | `Queue_unbind_ok _ -> (module Queue_unbind_ok : Method)
  | `Queue_purge _ -> (module Queue_purge : Method)
  | `Queue_purge_ok _ -> (module Queue_purge_ok : Method)
  | `Queue_delete _ -> (module Queue_delete : Method)
  | `Queue_delete_ok _ -> (module Queue_delete_ok : Method)
  | `Basic_qos _ -> (module Basic_qos : Method)
  | `Basic_qos_ok _ -> (module Basic_qos_ok : Method)
  | `Basic_consume _ -> (module Basic_consume : Method)
  | `Basic_consume_ok _ -> (module Basic_consume_ok : Method)
  | `Basic_cancel _ -> (module Basic_cancel : Method)
  | `Basic_cancel_ok _ -> (module Basic_cancel_ok : Method)
  | `Basic_publish _ -> (module Basic_publish : Method)
  | `Basic_return _ -> (module Basic_return : Method)
  | `Basic_deliver _ -> (module Basic_deliver : Method)
  | `Basic_get _ -> (module Basic_get : Method)
  | `Basic_get_ok _ -> (module Basic_get_ok : Method)
  | `Basic_get_empty _ -> (module Basic_get_empty : Method)
  | `Basic_ack _ -> (module Basic_ack : Method)
  | `Basic_reject _ -> (module Basic_reject : Method)
  | `Basic_recover_async _ -> (module Basic_recover_async : Method)
  | `Basic_recover _ -> (module Basic_recover : Method)
  | `Basic_recover_ok _ -> (module Basic_recover_ok : Method)
  | `Tx_select _ -> (module Tx_select : Method)
  | `Tx_select_ok _ -> (module Tx_select_ok : Method)
  | `Tx_commit _ -> (module Tx_commit : Method)
  | `Tx_commit_ok _ -> (module Tx_commit_ok : Method)
  | `Tx_rollback _ -> (module Tx_rollback : Method)
  | `Tx_rollback_ok _ -> (module Tx_rollback_ok : Method)
