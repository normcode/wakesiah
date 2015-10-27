defmodule Wakesiah.Tasks do

  require Logger

  def ping(fd, peer_addr, inc) do
    Task.async(fn ->
      Logger.debug("Pinging #{inspect fd} #{inspect peer_addr} #{inspect inc}")
      try do
        case Wakesiah.ping(peer_addr, inc) do
          response = {:ack, peer_inc} ->
            Logger.debug("Received #{inspect response} from #{inspect peer_addr}")
            Wakesiah.FailureDetector.update(fd, peer_addr, {:alive, peer_inc}) # TODO
        end
      catch
        :exit, _reason ->
          Logger.debug("Timeout from #{inspect peer_addr} #{inspect inc}")
          Wakesiah.FailureDetector.update(fd, peer_addr, {:suspect, inc})
          :pang
      end
    end)
  end

  def broadcast(members, me, {peer_addr, event, inc}) do
    Task.async(fn ->
      # TODO call Wakesiah for disseminating join
      Logger.debug "broadcasting #{inspect [members, me, {peer_addr, event, inc}]}"
      :ok
    end)
  end

end
