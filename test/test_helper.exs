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

end

ExUnit.start(capture_log: true, exclude: exclude)
