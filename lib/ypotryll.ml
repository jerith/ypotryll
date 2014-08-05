

type client = Client_impl.client
type channel = Client_impl.channel


module Client = struct
  include Client_impl
  type t = client
end


module Channel = struct
  include Channel_impl
  type t = channel
end
