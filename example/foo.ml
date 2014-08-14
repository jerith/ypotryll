open Lwt

open Ypotryll.Methods


let printlf_pink format =
  Lwt_io.printlf ("\x1b[35m" ^^ format ^^ "\x1b[0m")


let callback channel payload content =
  printlf_pink "Received method: %s"
    (Frame.dump_method payload) >>
  match content with
  | None -> return_unit
  | Some (header, body) ->
    printlf_pink "Received content: %s \x1b[31m%S"
      (Frame.dump_header ((Int64.of_int (String.length body)), header)) body


let handle_deliver channel payload (properties, body) =
  let delivery_tag = payload.Ypotryll_methods.Basic_deliver.delivery_tag in
  printlf_pink "dtag: %Lu" delivery_tag >>
  Basic.ack channel ~delivery_tag ~multiple:false ()


let rec catch_frames channel =
  Ypotryll.get_method_with_content channel
  >>= function
  | None -> return_unit
  | Some (`Basic_deliver record as payload, Some content) ->
    handle_deliver channel record content >>
    callback (Ypotryll.get_channel_number channel) payload (Some content) >>
    catch_frames channel
  | Some (payload, content) ->
    callback (Ypotryll.get_channel_number channel) payload content >>
    catch_frames channel


let exchange_declare channel exchange type_ =
  Exchange.declare channel
    ~exchange ~type_ ~passive:false ~durable:false ~no_wait:false ~arguments:[]
    ()
  >>= fun _ ->
  printlf_pink "Exchange created: %s" exchange


let queue_declare channel queue =
  Queue.declare channel
    ~queue ~passive:false ~durable:false ~exclusive:false ~auto_delete:false
    ~no_wait:false ~arguments:[] ()
  >>= fun { Ypotryll_methods.Queue_declare_ok.queue } ->
  printlf_pink "queue created: %s" queue >>
  return queue


let queue_bind channel queue exchange routing_key =
  Queue.bind channel
    ~queue ~exchange ~routing_key ~no_wait:false ~arguments:[] ()
  >>= fun _ ->
  printlf_pink "queue bound to exchange: %s <- %s : %s"
    queue exchange routing_key


let basic_publish channel exchange routing_key content =
  Basic.publish channel ~exchange ~routing_key ~mandatory:true
    ~immediate:false (Ypotryll_contents.Basic.make_t ()) content


let basic_consume channel queue consumer_tag =
  Basic.consume channel
    ~queue ~consumer_tag ~no_local:false ~no_ack:false ~exclusive:false
    ~no_wait:false ~arguments:[] ()
  >>= fun { Ypotryll_methods.Basic_consume_ok.consumer_tag } ->
  printlf_pink "consumer created: %s" consumer_tag >>
  return consumer_tag


let do_stuff client =
  try_lwt
    lwt channel = Ypotryll.open_channel client in
    ignore_result (catch_frames channel);
    exchange_declare channel "foo" "direct" >>
    queue_declare channel ""
    >>= fun queue_name ->
    queue_bind channel queue_name "foo" "bar" >>
    Lwt_unix.sleep 0.1 >>
    basic_publish channel "foo" "bar" "thing1" >>
    Lwt_unix.sleep 0.1 >>
    basic_consume channel queue_name ""
    >>= fun consumer_tag ->
    Lwt_unix.sleep 0.1 >>
    basic_publish channel "foo" "bar" "thing2" >>
    Lwt_unix.sleep 0.1 >>
    Ypotryll.close_channel channel
  finally Ypotryll.close_connection client


let lwt_main =
  lwt client = Ypotryll.connect ~server:"localhost" () in
  try_lwt
    do_stuff client <&> Ypotryll.wait_for_shutdown client
  with Failure text -> Lwt_io.printlf "exception: %S" text >> return_unit


let () = Lwt_main.run lwt_main
