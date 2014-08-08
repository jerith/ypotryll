(* This file is generated. See the code_gen dir for details. *)


module Channel = struct

  (* TODO: open *)

  let open_ok channel () =
    let payload = Ypotryll_methods.Channel_open_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: flow *)

  let flow_ok channel ~active () =
    let payload = Ypotryll_methods.Channel_flow_ok.make_t ~active () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: close *)

  let close_ok channel () =
    let payload = Ypotryll_methods.Channel_close_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload
end


module Exchange = struct

  (* TODO: declare *)

  let declare_ok channel () =
    let payload = Ypotryll_methods.Exchange_declare_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: delete *)

  let delete_ok channel () =
    let payload = Ypotryll_methods.Exchange_delete_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload
end


module Queue = struct

  (* TODO: declare *)

  let declare_ok channel ~queue ~message_count ~consumer_count () =
    let payload = Ypotryll_methods.Queue_declare_ok.make_t ~queue ~message_count ~consumer_count () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: bind *)

  let bind_ok channel () =
    let payload = Ypotryll_methods.Queue_bind_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: unbind *)

  let unbind_ok channel () =
    let payload = Ypotryll_methods.Queue_unbind_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: purge *)

  let purge_ok channel ~message_count () =
    let payload = Ypotryll_methods.Queue_purge_ok.make_t ~message_count () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: delete *)

  let delete_ok channel ~message_count () =
    let payload = Ypotryll_methods.Queue_delete_ok.make_t ~message_count () in
    Connection.send_method_async channel.Connection.channel_io payload
end


module Basic = struct

  (* TODO: qos *)

  let qos_ok channel () =
    let payload = Ypotryll_methods.Basic_qos_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: consume *)

  let consume_ok channel ~consumer_tag () =
    let payload = Ypotryll_methods.Basic_consume_ok.make_t ~consumer_tag () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: cancel *)

  let cancel_ok channel ~consumer_tag () =
    let payload = Ypotryll_methods.Basic_cancel_ok.make_t ~consumer_tag () in
    Connection.send_method_async channel.Connection.channel_io payload

  let publish channel ~exchange ~routing_key ~mandatory ~immediate () =
    let payload = Ypotryll_methods.Basic_publish.make_t ~exchange ~routing_key ~mandatory ~immediate () in
    Connection.send_method_async channel.Connection.channel_io payload

  let return channel ~reply_code ~reply_text ~exchange ~routing_key () =
    let payload = Ypotryll_methods.Basic_return.make_t ~reply_code ~reply_text ~exchange ~routing_key () in
    Connection.send_method_async channel.Connection.channel_io payload

  let deliver channel ~consumer_tag ~delivery_tag ~redelivered ~exchange ~routing_key () =
    let payload = Ypotryll_methods.Basic_deliver.make_t ~consumer_tag ~delivery_tag ~redelivered ~exchange ~routing_key () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: get *)

  let get_ok channel ~delivery_tag ~redelivered ~exchange ~routing_key ~message_count () =
    let payload = Ypotryll_methods.Basic_get_ok.make_t ~delivery_tag ~redelivered ~exchange ~routing_key ~message_count () in
    Connection.send_method_async channel.Connection.channel_io payload

  let get_empty channel () =
    let payload = Ypotryll_methods.Basic_get_empty.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  let ack channel ~delivery_tag ~multiple () =
    let payload = Ypotryll_methods.Basic_ack.make_t ~delivery_tag ~multiple () in
    Connection.send_method_async channel.Connection.channel_io payload

  let reject channel ~delivery_tag ~requeue () =
    let payload = Ypotryll_methods.Basic_reject.make_t ~delivery_tag ~requeue () in
    Connection.send_method_async channel.Connection.channel_io payload

  let recover_async channel ~requeue () =
    let payload = Ypotryll_methods.Basic_recover_async.make_t ~requeue () in
    Connection.send_method_async channel.Connection.channel_io payload

  let recover channel ~requeue () =
    let payload = Ypotryll_methods.Basic_recover.make_t ~requeue () in
    Connection.send_method_async channel.Connection.channel_io payload

  let recover_ok channel () =
    let payload = Ypotryll_methods.Basic_recover_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload
end


module Tx = struct

  (* TODO: select *)

  let select_ok channel () =
    let payload = Ypotryll_methods.Tx_select_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: commit *)

  let commit_ok channel () =
    let payload = Ypotryll_methods.Tx_commit_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: rollback *)

  let rollback_ok channel () =
    let payload = Ypotryll_methods.Tx_rollback_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload
end