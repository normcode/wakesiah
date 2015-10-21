defmodule Wakesiah.Tasks do

  require Logger

  def ping(fd, peer_addr, inc) do
    Task.async(fn ->
      Logger.debug("Pinging #{inspect fd} #{inspect peer_addr} #{inspect inc}")
      case Wakesiah.ping(peer_addr, inc) do
        {:ack, peer_inc} = response ->
          Logger.debug("Received #{inspect response} from #{inspect peer_addr}")
          Wakesiah.FailureDetector.update(fd, peer_addr, {:alive, peer_inc}) # TODO
          :ack
        :pang ->
          Logger.debug("Timeout from #{inspect peer_addr} #{inspect inc}")
          Wakesiah.FailureDetector.update(fd, peer_addr, {:suspect, inc})
          :pang
      end
    end)
  end

end
