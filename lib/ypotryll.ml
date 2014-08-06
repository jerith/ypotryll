

type client = Connection.t
type channel = Client_impl.channel
type method_payload = Generated_method_types.method_payload


module Client = struct
  include Client_impl
  type t = client
end


module Channel = struct
  include Channel_impl
  type t = channel
end
