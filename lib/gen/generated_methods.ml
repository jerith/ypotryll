(* This file is generated. See the code_gen dir for details. *)


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

module Connection_start_ok = struct
  include Gen_connection_start_ok.Connection_start_ok

  type t = [`Connection_start_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Connection_start_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Connection_start_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_start_ok payload -> t_to_list payload
    | _ -> assert false
end

module Connection_secure = struct
  include Gen_connection_secure.Connection_secure

  type t = [`Connection_secure of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Connection_secure (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Connection_secure payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_secure payload -> t_to_list payload
    | _ -> assert false
end

module Connection_secure_ok = struct
  include Gen_connection_secure_ok.Connection_secure_ok

  type t = [`Connection_secure_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Connection_secure_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Connection_secure_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_secure_ok payload -> t_to_list payload
    | _ -> assert false
end

module Connection_tune = struct
  include Gen_connection_tune.Connection_tune

  type t = [`Connection_tune of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Connection_tune (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Connection_tune payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_tune payload -> t_to_list payload
    | _ -> assert false
end

module Connection_tune_ok = struct
  include Gen_connection_tune_ok.Connection_tune_ok

  type t = [`Connection_tune_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Connection_tune_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Connection_tune_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_tune_ok payload -> t_to_list payload
    | _ -> assert false
end

module Connection_open = struct
  include Gen_connection_open.Connection_open

  type t = [`Connection_open of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Connection_open (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Connection_open payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_open payload -> t_to_list payload
    | _ -> assert false
end

module Connection_open_ok = struct
  include Gen_connection_open_ok.Connection_open_ok

  type t = [`Connection_open_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Connection_open_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Connection_open_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_open_ok payload -> t_to_list payload
    | _ -> assert false
end

module Connection_close = struct
  include Gen_connection_close.Connection_close

  type t = [`Connection_close of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Connection_close (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Connection_close payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_close payload -> t_to_list payload
    | _ -> assert false
end

module Connection_close_ok = struct
  include Gen_connection_close_ok.Connection_close_ok

  type t = [`Connection_close_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Connection_close_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Connection_close_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Connection_close_ok payload -> t_to_list payload
    | _ -> assert false
end

module Channel_open = struct
  include Gen_channel_open.Channel_open

  type t = [`Channel_open of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Channel_open (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Channel_open payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_open payload -> t_to_list payload
    | _ -> assert false
end

module Channel_open_ok = struct
  include Gen_channel_open_ok.Channel_open_ok

  type t = [`Channel_open_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Channel_open_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Channel_open_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_open_ok payload -> t_to_list payload
    | _ -> assert false
end

module Channel_flow = struct
  include Gen_channel_flow.Channel_flow

  type t = [`Channel_flow of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Channel_flow (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Channel_flow payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_flow payload -> t_to_list payload
    | _ -> assert false
end

module Channel_flow_ok = struct
  include Gen_channel_flow_ok.Channel_flow_ok

  type t = [`Channel_flow_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Channel_flow_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Channel_flow_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_flow_ok payload -> t_to_list payload
    | _ -> assert false
end

module Channel_close = struct
  include Gen_channel_close.Channel_close

  type t = [`Channel_close of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Channel_close (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Channel_close payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_close payload -> t_to_list payload
    | _ -> assert false
end

module Channel_close_ok = struct
  include Gen_channel_close_ok.Channel_close_ok

  type t = [`Channel_close_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Channel_close_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Channel_close_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Channel_close_ok payload -> t_to_list payload
    | _ -> assert false
end

module Exchange_declare = struct
  include Gen_exchange_declare.Exchange_declare

  type t = [`Exchange_declare of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Exchange_declare (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Exchange_declare payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Exchange_declare payload -> t_to_list payload
    | _ -> assert false
end

module Exchange_declare_ok = struct
  include Gen_exchange_declare_ok.Exchange_declare_ok

  type t = [`Exchange_declare_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Exchange_declare_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Exchange_declare_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Exchange_declare_ok payload -> t_to_list payload
    | _ -> assert false
end

module Exchange_delete = struct
  include Gen_exchange_delete.Exchange_delete

  type t = [`Exchange_delete of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Exchange_delete (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Exchange_delete payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Exchange_delete payload -> t_to_list payload
    | _ -> assert false
end

module Exchange_delete_ok = struct
  include Gen_exchange_delete_ok.Exchange_delete_ok

  type t = [`Exchange_delete_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Exchange_delete_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Exchange_delete_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Exchange_delete_ok payload -> t_to_list payload
    | _ -> assert false
end

module Queue_declare = struct
  include Gen_queue_declare.Queue_declare

  type t = [`Queue_declare of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Queue_declare (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Queue_declare payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_declare payload -> t_to_list payload
    | _ -> assert false
end

module Queue_declare_ok = struct
  include Gen_queue_declare_ok.Queue_declare_ok

  type t = [`Queue_declare_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Queue_declare_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Queue_declare_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_declare_ok payload -> t_to_list payload
    | _ -> assert false
end

module Queue_bind = struct
  include Gen_queue_bind.Queue_bind

  type t = [`Queue_bind of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Queue_bind (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Queue_bind payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_bind payload -> t_to_list payload
    | _ -> assert false
end

module Queue_bind_ok = struct
  include Gen_queue_bind_ok.Queue_bind_ok

  type t = [`Queue_bind_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Queue_bind_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Queue_bind_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_bind_ok payload -> t_to_list payload
    | _ -> assert false
end

module Queue_unbind = struct
  include Gen_queue_unbind.Queue_unbind

  type t = [`Queue_unbind of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Queue_unbind (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Queue_unbind payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_unbind payload -> t_to_list payload
    | _ -> assert false
end

module Queue_unbind_ok = struct
  include Gen_queue_unbind_ok.Queue_unbind_ok

  type t = [`Queue_unbind_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Queue_unbind_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Queue_unbind_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_unbind_ok payload -> t_to_list payload
    | _ -> assert false
end

module Queue_purge = struct
  include Gen_queue_purge.Queue_purge

  type t = [`Queue_purge of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Queue_purge (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Queue_purge payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_purge payload -> t_to_list payload
    | _ -> assert false
end

module Queue_purge_ok = struct
  include Gen_queue_purge_ok.Queue_purge_ok

  type t = [`Queue_purge_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Queue_purge_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Queue_purge_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_purge_ok payload -> t_to_list payload
    | _ -> assert false
end

module Queue_delete = struct
  include Gen_queue_delete.Queue_delete

  type t = [`Queue_delete of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Queue_delete (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Queue_delete payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_delete payload -> t_to_list payload
    | _ -> assert false
end

module Queue_delete_ok = struct
  include Gen_queue_delete_ok.Queue_delete_ok

  type t = [`Queue_delete_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Queue_delete_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Queue_delete_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Queue_delete_ok payload -> t_to_list payload
    | _ -> assert false
end

module Basic_qos = struct
  include Gen_basic_qos.Basic_qos

  type t = [`Basic_qos of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_qos (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_qos payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_qos payload -> t_to_list payload
    | _ -> assert false
end

module Basic_qos_ok = struct
  include Gen_basic_qos_ok.Basic_qos_ok

  type t = [`Basic_qos_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_qos_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_qos_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_qos_ok payload -> t_to_list payload
    | _ -> assert false
end

module Basic_consume = struct
  include Gen_basic_consume.Basic_consume

  type t = [`Basic_consume of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_consume (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_consume payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_consume payload -> t_to_list payload
    | _ -> assert false
end

module Basic_consume_ok = struct
  include Gen_basic_consume_ok.Basic_consume_ok

  type t = [`Basic_consume_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_consume_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_consume_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_consume_ok payload -> t_to_list payload
    | _ -> assert false
end

module Basic_cancel = struct
  include Gen_basic_cancel.Basic_cancel

  type t = [`Basic_cancel of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_cancel (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_cancel payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_cancel payload -> t_to_list payload
    | _ -> assert false
end

module Basic_cancel_ok = struct
  include Gen_basic_cancel_ok.Basic_cancel_ok

  type t = [`Basic_cancel_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_cancel_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_cancel_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_cancel_ok payload -> t_to_list payload
    | _ -> assert false
end

module Basic_publish = struct
  include Gen_basic_publish.Basic_publish

  type t = [`Basic_publish of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_publish (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_publish payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_publish payload -> t_to_list payload
    | _ -> assert false
end

module Basic_return = struct
  include Gen_basic_return.Basic_return

  type t = [`Basic_return of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_return (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_return payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_return payload -> t_to_list payload
    | _ -> assert false
end

module Basic_deliver = struct
  include Gen_basic_deliver.Basic_deliver

  type t = [`Basic_deliver of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_deliver (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_deliver payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_deliver payload -> t_to_list payload
    | _ -> assert false
end

module Basic_get = struct
  include Gen_basic_get.Basic_get

  type t = [`Basic_get of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_get (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_get payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_get payload -> t_to_list payload
    | _ -> assert false
end

module Basic_get_ok = struct
  include Gen_basic_get_ok.Basic_get_ok

  type t = [`Basic_get_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_get_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_get_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_get_ok payload -> t_to_list payload
    | _ -> assert false
end

module Basic_get_empty = struct
  include Gen_basic_get_empty.Basic_get_empty

  type t = [`Basic_get_empty of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_get_empty (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_get_empty payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_get_empty payload -> t_to_list payload
    | _ -> assert false
end

module Basic_ack = struct
  include Gen_basic_ack.Basic_ack

  type t = [`Basic_ack of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_ack (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_ack payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_ack payload -> t_to_list payload
    | _ -> assert false
end

module Basic_reject = struct
  include Gen_basic_reject.Basic_reject

  type t = [`Basic_reject of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_reject (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_reject payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_reject payload -> t_to_list payload
    | _ -> assert false
end

module Basic_recover_async = struct
  include Gen_basic_recover_async.Basic_recover_async

  type t = [`Basic_recover_async of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_recover_async (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_recover_async payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_recover_async payload -> t_to_list payload
    | _ -> assert false
end

module Basic_recover = struct
  include Gen_basic_recover.Basic_recover

  type t = [`Basic_recover of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_recover (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_recover payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_recover payload -> t_to_list payload
    | _ -> assert false
end

module Basic_recover_ok = struct
  include Gen_basic_recover_ok.Basic_recover_ok

  type t = [`Basic_recover_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Basic_recover_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Basic_recover_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Basic_recover_ok payload -> t_to_list payload
    | _ -> assert false
end

module Tx_select = struct
  include Gen_tx_select.Tx_select

  type t = [`Tx_select of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Tx_select (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Tx_select payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_select payload -> t_to_list payload
    | _ -> assert false
end

module Tx_select_ok = struct
  include Gen_tx_select_ok.Tx_select_ok

  type t = [`Tx_select_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Tx_select_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Tx_select_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_select_ok payload -> t_to_list payload
    | _ -> assert false
end

module Tx_commit = struct
  include Gen_tx_commit.Tx_commit

  type t = [`Tx_commit of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Tx_commit (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Tx_commit payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_commit payload -> t_to_list payload
    | _ -> assert false
end

module Tx_commit_ok = struct
  include Gen_tx_commit_ok.Tx_commit_ok

  type t = [`Tx_commit_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Tx_commit_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Tx_commit_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_commit_ok payload -> t_to_list payload
    | _ -> assert false
end

module Tx_rollback = struct
  include Gen_tx_rollback.Tx_rollback

  type t = [`Tx_rollback of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Tx_rollback (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Tx_rollback payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_rollback payload -> t_to_list payload
    | _ -> assert false
end

module Tx_rollback_ok = struct
  include Gen_tx_rollback_ok.Tx_rollback_ok

  type t = [`Tx_rollback_ok of record]

  let buf_to_list = Protocol.Method_utils.buf_to_list arguments

  let string_of_list = Protocol.Method_utils.string_of_list arguments

  let parse_method buf =
    (`Tx_rollback_ok (t_from_list (buf_to_list buf)) :> Generated_method_types.method_payload)

  let build_method = function
    | `Tx_rollback_ok payload -> string_of_list (t_to_list payload)
    | _ -> assert false

  let list_of_t = function
    | `Tx_rollback_ok payload -> t_to_list payload
    | _ -> assert false
end

let build_method_instance = function
  | (10, 10) -> (Stubs.build_payload (module Connection_start))
  | (10, 11) -> (Stubs.build_payload (module Connection_start_ok))
  | (10, 20) -> (Stubs.build_payload (module Connection_secure))
  | (10, 21) -> (Stubs.build_payload (module Connection_secure_ok))
  | (10, 30) -> (Stubs.build_payload (module Connection_tune))
  | (10, 31) -> (Stubs.build_payload (module Connection_tune_ok))
  | (10, 40) -> (Stubs.build_payload (module Connection_open))
  | (10, 41) -> (Stubs.build_payload (module Connection_open_ok))
  | (10, 50) -> (Stubs.build_payload (module Connection_close))
  | (10, 51) -> (Stubs.build_payload (module Connection_close_ok))
  | (20, 10) -> (Stubs.build_payload (module Channel_open))
  | (20, 11) -> (Stubs.build_payload (module Channel_open_ok))
  | (20, 20) -> (Stubs.build_payload (module Channel_flow))
  | (20, 21) -> (Stubs.build_payload (module Channel_flow_ok))
  | (20, 40) -> (Stubs.build_payload (module Channel_close))
  | (20, 41) -> (Stubs.build_payload (module Channel_close_ok))
  | (40, 10) -> (Stubs.build_payload (module Exchange_declare))
  | (40, 11) -> (Stubs.build_payload (module Exchange_declare_ok))
  | (40, 20) -> (Stubs.build_payload (module Exchange_delete))
  | (40, 21) -> (Stubs.build_payload (module Exchange_delete_ok))
  | (50, 10) -> (Stubs.build_payload (module Queue_declare))
  | (50, 11) -> (Stubs.build_payload (module Queue_declare_ok))
  | (50, 20) -> (Stubs.build_payload (module Queue_bind))
  | (50, 21) -> (Stubs.build_payload (module Queue_bind_ok))
  | (50, 50) -> (Stubs.build_payload (module Queue_unbind))
  | (50, 51) -> (Stubs.build_payload (module Queue_unbind_ok))
  | (50, 30) -> (Stubs.build_payload (module Queue_purge))
  | (50, 31) -> (Stubs.build_payload (module Queue_purge_ok))
  | (50, 40) -> (Stubs.build_payload (module Queue_delete))
  | (50, 41) -> (Stubs.build_payload (module Queue_delete_ok))
  | (60, 10) -> (Stubs.build_payload (module Basic_qos))
  | (60, 11) -> (Stubs.build_payload (module Basic_qos_ok))
  | (60, 20) -> (Stubs.build_payload (module Basic_consume))
  | (60, 21) -> (Stubs.build_payload (module Basic_consume_ok))
  | (60, 30) -> (Stubs.build_payload (module Basic_cancel))
  | (60, 31) -> (Stubs.build_payload (module Basic_cancel_ok))
  | (60, 40) -> (Stubs.build_payload (module Basic_publish))
  | (60, 50) -> (Stubs.build_payload (module Basic_return))
  | (60, 60) -> (Stubs.build_payload (module Basic_deliver))
  | (60, 70) -> (Stubs.build_payload (module Basic_get))
  | (60, 71) -> (Stubs.build_payload (module Basic_get_ok))
  | (60, 72) -> (Stubs.build_payload (module Basic_get_empty))
  | (60, 80) -> (Stubs.build_payload (module Basic_ack))
  | (60, 90) -> (Stubs.build_payload (module Basic_reject))
  | (60, 100) -> (Stubs.build_payload (module Basic_recover_async))
  | (60, 110) -> (Stubs.build_payload (module Basic_recover))
  | (60, 111) -> (Stubs.build_payload (module Basic_recover_ok))
  | (90, 10) -> (Stubs.build_payload (module Tx_select))
  | (90, 11) -> (Stubs.build_payload (module Tx_select_ok))
  | (90, 20) -> (Stubs.build_payload (module Tx_commit))
  | (90, 21) -> (Stubs.build_payload (module Tx_commit_ok))
  | (90, 30) -> (Stubs.build_payload (module Tx_rollback))
  | (90, 31) -> (Stubs.build_payload (module Tx_rollback_ok))
  | (class_id, method_id) ->
    failwith (Printf.sprintf "Unknown method: (%d, %d)" class_id method_id)
