(* This file is generated. See the code_gen dir for details. *)


type method_payload = [
  | `Connection_start of Gen_connection_start.Connection_start.record
  | `Connection_start_ok of Gen_connection_start_ok.Connection_start_ok.record
  | `Connection_secure of Gen_connection_secure.Connection_secure.record
  | `Connection_secure_ok of Gen_connection_secure_ok.Connection_secure_ok.record
  | `Connection_tune of Gen_connection_tune.Connection_tune.record
  | `Connection_tune_ok of Gen_connection_tune_ok.Connection_tune_ok.record
  | `Connection_open of Gen_connection_open.Connection_open.record
  | `Connection_open_ok of Gen_connection_open_ok.Connection_open_ok.record
  | `Connection_close of Gen_connection_close.Connection_close.record
  | `Connection_close_ok of Gen_connection_close_ok.Connection_close_ok.record
  | `Channel_open of Gen_channel_open.Channel_open.record
  | `Channel_open_ok of Gen_channel_open_ok.Channel_open_ok.record
  | `Channel_flow of Gen_channel_flow.Channel_flow.record
  | `Channel_flow_ok of Gen_channel_flow_ok.Channel_flow_ok.record
  | `Channel_close of Gen_channel_close.Channel_close.record
  | `Channel_close_ok of Gen_channel_close_ok.Channel_close_ok.record
  | `Exchange_declare of Gen_exchange_declare.Exchange_declare.record
  | `Exchange_declare_ok of Gen_exchange_declare_ok.Exchange_declare_ok.record
  | `Exchange_delete of Gen_exchange_delete.Exchange_delete.record
  | `Exchange_delete_ok of Gen_exchange_delete_ok.Exchange_delete_ok.record
  | `Queue_declare of Gen_queue_declare.Queue_declare.record
  | `Queue_declare_ok of Gen_queue_declare_ok.Queue_declare_ok.record
  | `Queue_bind of Gen_queue_bind.Queue_bind.record
  | `Queue_bind_ok of Gen_queue_bind_ok.Queue_bind_ok.record
  | `Queue_unbind of Gen_queue_unbind.Queue_unbind.record
  | `Queue_unbind_ok of Gen_queue_unbind_ok.Queue_unbind_ok.record
  | `Queue_purge of Gen_queue_purge.Queue_purge.record
  | `Queue_purge_ok of Gen_queue_purge_ok.Queue_purge_ok.record
  | `Queue_delete of Gen_queue_delete.Queue_delete.record
  | `Queue_delete_ok of Gen_queue_delete_ok.Queue_delete_ok.record
  | `Basic_qos of Gen_basic_qos.Basic_qos.record
  | `Basic_qos_ok of Gen_basic_qos_ok.Basic_qos_ok.record
  | `Basic_consume of Gen_basic_consume.Basic_consume.record
  | `Basic_consume_ok of Gen_basic_consume_ok.Basic_consume_ok.record
  | `Basic_cancel of Gen_basic_cancel.Basic_cancel.record
  | `Basic_cancel_ok of Gen_basic_cancel_ok.Basic_cancel_ok.record
  | `Basic_publish of Gen_basic_publish.Basic_publish.record
  | `Basic_return of Gen_basic_return.Basic_return.record
  | `Basic_deliver of Gen_basic_deliver.Basic_deliver.record
  | `Basic_get of Gen_basic_get.Basic_get.record
  | `Basic_get_ok of Gen_basic_get_ok.Basic_get_ok.record
  | `Basic_get_empty of Gen_basic_get_empty.Basic_get_empty.record
  | `Basic_ack of Gen_basic_ack.Basic_ack.record
  | `Basic_reject of Gen_basic_reject.Basic_reject.record
  | `Basic_recover_async of Gen_basic_recover_async.Basic_recover_async.record
  | `Basic_recover of Gen_basic_recover.Basic_recover.record
  | `Basic_recover_ok of Gen_basic_recover_ok.Basic_recover_ok.record
  | `Tx_select of Gen_tx_select.Tx_select.record
  | `Tx_select_ok of Gen_tx_select_ok.Tx_select_ok.record
  | `Tx_commit of Gen_tx_commit.Tx_commit.record
  | `Tx_commit_ok of Gen_tx_commit_ok.Tx_commit_ok.record
  | `Tx_rollback of Gen_tx_rollback.Tx_rollback.record
  | `Tx_rollback_ok of Gen_tx_rollback_ok.Tx_rollback_ok.record
]

module type Method = sig
  type t

  val class_id : int

  val method_id : int

  val parse_method : Parse_utils.Parse_buf.t -> method_payload

  val build_method : method_payload -> string

  (* temporary? *)

  val buf_to_list : Parse_utils.Parse_buf.t -> (string * Protocol.Amqp_field.t) list

  val string_of_list : (string * Protocol.Amqp_field.t) list -> string

  val list_of_t : method_payload -> (string * Protocol.Amqp_field.t) list
end
