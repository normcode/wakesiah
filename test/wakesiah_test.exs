defmodule WakesiahTest do
  require Logger
  use ExUnit.Case, async: true

  setup context do
    {:ok, pid} = Wakesiah.Supervisor.start_link(
      worker_name: context.test,
      failure_detector: String.to_atom("#{context.test} failure detector"))

    on_exit fn ->
      Wakesiah.stop pid
    end

    {:ok, [pid: context.test]}
  end

  test "members on start", context do
    assert [] = Wakesiah.members(context.pid)
  end

  test "members with seeding", context do
    {:ok, _} = Wakesiah.Supervisor.start_link(
      seeds: [:peer_addr],
      worker_name: String.to_atom("#{context.line}"),
      failure_detector: String.to_atom("#{context.line} failure detector"))
    assert [:peer_addr] = Wakesiah.members(String.to_atom("#{context.line}"))
  end

  test "ping" do
    test_pid = self
    task = Task.async(fn -> Wakesiah.ping(test_pid, 0) end)
    assert_receive {:"$gen_call", msg, {:ping, 0}}
    GenServer.reply(msg, :ack)
    assert :ack = Task.await(task)
  end

  test "ping timeout" do
    :pang = Wakesiah.ping(self, 0)
    assert_receive {:"$gen_call", _, {:ping, 0}}
  end

  test "task" do
    task = Wakesiah.Tasks.ping(:fd, self, 0)
    :pang = Task.await(task)
    assert_receive {:"$gen_call", _, {:ping, 0}}
  end

  @tag :skip
  test "join", context do
    {:ok, peer} = Wakesiah.start_link(name: :"another #{context.test}")
    assert :ok = Wakesiah.join(context.pid, :"another #{context.test}", {peer, node()})
    assert Wakesiah.members(context.pid) == []
    assert Wakesiah.members(String.to_atom("another #{context.test}")) == [{:"another #{context.test}", node()}]
  end

end
