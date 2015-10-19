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
      :ack
    end)
  end

end

ExUnit.start(exclude: exclude)
