defmodule Wakesiah.Ping do
  # TODO
  @callback ping(fd :: pid(), peer_addr :: any(), inc :: any(), gossip :: any()) :: any()
end

defmodule Wakesiah.Tasks do

  @behaviour Wakesiah.Ping

  require Logger

  def ping(fd, peer_addr, inc, gossip) do
    Task.async(fn ->
      Logger.debug("Pinging #{inspect fd} #{inspect peer_addr} #{inspect inc} #{inspect gossip}")
      try do
        case Wakesiah.ping(peer_addr, inc, gossip) do
          response = {:ack, peer_inc} ->
            Logger.debug("Received #{inspect response} from #{inspect peer_addr}")
            Wakesiah.FailureDetector.update(fd, peer_addr, {:alive, peer_inc}) # TODO ??
        end
      catch
        :exit, _reason ->
          Logger.debug("Timeout from #{inspect peer_addr} #{inspect inc}")
          Wakesiah.FailureDetector.update(fd, peer_addr, {:suspect, inc})
          :pang
      end
    end)
  end

end
