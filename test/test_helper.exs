exclude = [distributed: not Node.alive?]

defmodule Test.PingSelf do

  @behaviour Wakesiah.Ping

  def register_test() do
    Process.register(self, :test_pid)
  end

  def ping(_) do
    pid = Process.whereis(:test_pid)
    send(pid, :ping)
  end

end

ExUnit.start(exclude: exclude)
