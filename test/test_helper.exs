exclude = [distributed: not Node.alive?]

defmodule Test.Tasks do

  @behaviour Wakesiah.Tasks

  def register_test() do
    Process.register(self, :test_pid)
  end

  def ping(fd, peer_addr, seq) do
    pid = Process.whereis(:test_pid)
    Task.async(fn ->
      send(pid, {:ping, fd, peer_addr, seq})
      :ok
    end)
  end

  def broadcast(peers, me, {peer_addr, event, inc}) do
    pid = Process.whereis(:test_pid)
    Task.async(fn ->
      require Logger
      Logger.debug("Broadcasting from #{inspect me} #{inspect {peer_addr, event, inc}} to #{inspect peers}")
      send pid, {:broadcast, [peers, me, {peer_addr, event, inc}]}
      :ok
    end)
  end

end

ExUnit.start(capture_log: true, exclude: exclude)
