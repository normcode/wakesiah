defmodule Wakesiah.Ping do

  @callback ping(peer_addr :: any()) :: any()

end
