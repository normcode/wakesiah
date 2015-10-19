defmodule Wakesiah.Tasks do

  def ping(fd, peer_addr, incarnation) do
    Task.async(fn ->
      case Wakesiah.ping(peer_addr, incarnation) do
        {:ack, i} ->
          Wakesiah.FailureDetector.update(fd, peer_addr, {:alive, i})
        :pang -> :pang
      end
    end)
  end

end
