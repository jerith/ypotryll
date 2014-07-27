





module Connection_start = struct
  include Gen_method_defs.Connection_start_definition
  include Method.Make_payload_marshaller_ext(Gen_method_defs.Connection_start_definition)
end



let method_modules = [
  (10, 10), (module Connection_start : Method.Make_method_payload(Connection_start_definition) : Method.Amqp_method_payload);
]
