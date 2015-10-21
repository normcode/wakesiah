defmodule Wakesiah.Tasks do

  require Logger

  def ping(fd, peer_addr, inc) do
    Task.async(fn ->
      case Wakesiah.ping(peer_addr, inc) do
        {:ack, peer_inc} = response ->
          Logger.debug("Received #{inspect response} from #{inspect peer_addr}")
          Wakesiah.FailureDetector.update(fd, peer_addr, {:alive, peer_inc}) # TODO
        :pang ->
          Logger.debug("Timeout from #{inspect peer_addr} #{inspect inc}")
          Wakesiah.FailureDetector.update(fd, peer_addr, {:suspect, inc})
      end
    end)
  end

end
