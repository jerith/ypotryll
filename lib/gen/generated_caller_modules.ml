(* This file is generated. See the code_gen dir for details. *)


module Channel = struct

  let open_ channel () =
    let open Lwt in
    let payload = Ypotryll_methods.Channel_open.make_t () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Channel_open_ok payload -> payload
    | _ -> assert false

  let open_ok channel () =
    let payload = Ypotryll_methods.Channel_open_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  let flow channel ~active () =
    let open Lwt in
    let payload = Ypotryll_methods.Channel_flow.make_t ~active () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Channel_flow_ok payload -> payload
    | _ -> assert false

  let flow_ok channel ~active () =
    let payload = Ypotryll_methods.Channel_flow_ok.make_t ~active () in
    Connection.send_method_async channel.Connection.channel_io payload

  let close channel ~reply_code ~reply_text ~class_id ~method_id () =
    let open Lwt in
    let payload = Ypotryll_methods.Channel_close.make_t ~reply_code ~reply_text ~class_id ~method_id () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Channel_close_ok payload -> payload
    | _ -> assert false

  let close_ok channel () =
    let payload = Ypotryll_methods.Channel_close_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload
end


module Exchange = struct

  let declare channel ~exchange ~type_ ~passive ~durable ~no_wait ~arguments () =
    let open Lwt in
    let payload = Ypotryll_methods.Exchange_declare.make_t ~exchange ~type_ ~passive ~durable ~no_wait ~arguments () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Exchange_declare_ok payload -> payload
    | _ -> assert false

  let declare_ok channel () =
    let payload = Ypotryll_methods.Exchange_declare_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  let delete channel ~exchange ~if_unused ~no_wait () =
    let open Lwt in
    let payload = Ypotryll_methods.Exchange_delete.make_t ~exchange ~if_unused ~no_wait () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Exchange_delete_ok payload -> payload
    | _ -> assert false

  let delete_ok channel () =
    let payload = Ypotryll_methods.Exchange_delete_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload
end


module Queue = struct

  let declare channel ~queue ~passive ~durable ~exclusive ~auto_delete ~no_wait ~arguments () =
    let open Lwt in
    let payload = Ypotryll_methods.Queue_declare.make_t ~queue ~passive ~durable ~exclusive ~auto_delete ~no_wait ~arguments () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Queue_declare_ok payload -> payload
    | _ -> assert false

  let declare_ok channel ~queue ~message_count ~consumer_count () =
    let payload = Ypotryll_methods.Queue_declare_ok.make_t ~queue ~message_count ~consumer_count () in
    Connection.send_method_async channel.Connection.channel_io payload

  let bind channel ~queue ~exchange ~routing_key ~no_wait ~arguments () =
    let open Lwt in
    let payload = Ypotryll_methods.Queue_bind.make_t ~queue ~exchange ~routing_key ~no_wait ~arguments () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Queue_bind_ok payload -> payload
    | _ -> assert false

  let bind_ok channel () =
    let payload = Ypotryll_methods.Queue_bind_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  let unbind channel ~queue ~exchange ~routing_key ~arguments () =
    let open Lwt in
    let payload = Ypotryll_methods.Queue_unbind.make_t ~queue ~exchange ~routing_key ~arguments () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Queue_unbind_ok payload -> payload
    | _ -> assert false

  let unbind_ok channel () =
    let payload = Ypotryll_methods.Queue_unbind_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  let purge channel ~queue ~no_wait () =
    let open Lwt in
    let payload = Ypotryll_methods.Queue_purge.make_t ~queue ~no_wait () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Queue_purge_ok payload -> payload
    | _ -> assert false

  let purge_ok channel ~message_count () =
    let payload = Ypotryll_methods.Queue_purge_ok.make_t ~message_count () in
    Connection.send_method_async channel.Connection.channel_io payload

  let delete channel ~queue ~if_unused ~if_empty ~no_wait () =
    let open Lwt in
    let payload = Ypotryll_methods.Queue_delete.make_t ~queue ~if_unused ~if_empty ~no_wait () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Queue_delete_ok payload -> payload
    | _ -> assert false

  let delete_ok channel ~message_count () =
    let payload = Ypotryll_methods.Queue_delete_ok.make_t ~message_count () in
    Connection.send_method_async channel.Connection.channel_io payload
end


module Basic = struct

  let qos channel ~prefetch_size ~prefetch_count ~global () =
    let open Lwt in
    let payload = Ypotryll_methods.Basic_qos.make_t ~prefetch_size ~prefetch_count ~global () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Basic_qos_ok payload -> payload
    | _ -> assert false

  let qos_ok channel () =
    let payload = Ypotryll_methods.Basic_qos_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  let consume channel ~queue ~consumer_tag ~no_local ~no_ack ~exclusive ~no_wait ~arguments () =
    let open Lwt in
    let payload = Ypotryll_methods.Basic_consume.make_t ~queue ~consumer_tag ~no_local ~no_ack ~exclusive ~no_wait ~arguments () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Basic_consume_ok payload -> payload
    | _ -> assert false

  let consume_ok channel ~consumer_tag () =
    let payload = Ypotryll_methods.Basic_consume_ok.make_t ~consumer_tag () in
    Connection.send_method_async channel.Connection.channel_io payload

  let cancel channel ~consumer_tag ~no_wait () =
    let open Lwt in
    let payload = Ypotryll_methods.Basic_cancel.make_t ~consumer_tag ~no_wait () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Basic_cancel_ok payload -> payload
    | _ -> assert false

  let cancel_ok channel ~consumer_tag () =
    let payload = Ypotryll_methods.Basic_cancel_ok.make_t ~consumer_tag () in
    Connection.send_method_async channel.Connection.channel_io payload

  (* TODO: publish 0 *)

  (* TODO: return 0 *)

  (* TODO: deliver 0 *)

  let get channel ~queue ~no_ack () =
    let open Lwt in
    let payload = Ypotryll_methods.Basic_get.make_t ~queue ~no_ack () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Basic_get_ok payload -> `Get_ok payload
    | `Basic_get_empty payload -> `Get_empty payload
    | _ -> assert false

  (* TODO: get-ok 0 *)

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

  let select channel () =
    let open Lwt in
    let payload = Ypotryll_methods.Tx_select.make_t () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Tx_select_ok payload -> payload
    | _ -> assert false

  let select_ok channel () =
    let payload = Ypotryll_methods.Tx_select_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  let commit channel () =
    let open Lwt in
    let payload = Ypotryll_methods.Tx_commit.make_t () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Tx_commit_ok payload -> payload
    | _ -> assert false

  let commit_ok channel () =
    let payload = Ypotryll_methods.Tx_commit_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload

  let rollback channel () =
    let open Lwt in
    let payload = Ypotryll_methods.Tx_rollback.make_t () in
    Connection.send_method_sync channel.Connection.channel_io payload
    >|= function
    | `Tx_rollback_ok payload -> payload
    | _ -> assert false

  let rollback_ok channel () =
    let payload = Ypotryll_methods.Tx_rollback_ok.make_t () in
    Connection.send_method_async channel.Connection.channel_io payload
end