defmodule Wakesiah.FailureDetectorTest do

  use ExUnit.Case, async: true

  alias Wakesiah.FailureDetector, as: FD

  setup_all do
    Application.put_env(:wakesiah, :task_mod, Test.Tasks)
    on_exit fn ->
      Application.delete_env(:wakesiah, :task_mod)
    end
  end
  
  setup context do
    Test.Tasks.register_test
    {:ok, [name: context.test]}
  end

  def start_detector(options, context) do
    opts = Keyword.put_new(options, :name, context[:name])
    FD.start_link(opts)
  end

  test "start", context do
    {:ok, pid} = start_detector([], context)
    assert [] == FD.members(pid)
  end

  test "start without seeds", context do
    {:ok, pid} = start_detector([seeds: []], context)
    assert [] == FD.members(pid)
  end

  test "start with seeds", context do
    {:ok, pid} = start_detector([seeds: [:peer_addr]], context)
    assert [:peer_addr] == FD.members(pid)
  end

  test "test update", context do
    {:ok, pid} = start_detector([seeds: [:peer_addr]], context)
    assert :ok = FD.update(pid, :peer_addr, {:alive, 10})
    assert :ok = FD.update(pid, :peer_addr, {:alive, 9})
    assert :ok = FD.update(pid, :peer_addr, {:suspect, 10})
    assert :ok = FD.update(pid, :peer_addr, {:suspect, 20})
    assert :ok = FD.update(pid, :peer_addr, {:suspect, 19})
    assert :ok = FD.update(pid, :peer_addr, {:alive, 19})
    assert :ok = FD.update(pid, :peer_addr, {:alive, 21})
    assert :ok = FD.update(pid, :peer_addr, {:suspect, 22})
    assert :ok = FD.update(pid, :peer_addr, {:suspect, 22})
    assert :ok = FD.update(pid, :peer_addr, {:failed, 23})
    assert :ok = FD.update(pid, :peer_addr, {:alive, 24})
    assert :ok = FD.update(pid, :peer_addr, {:failed, 25})
    assert :ok = FD.update(pid, :peer_addr, {:suspect, 26})
  end

  test "receiver timer", context do
    {:ok, pid} = start_detector([seeds: [:peer_addr]], context)
    send(pid, :tick)
    :timer.sleep(10)
    assert_receive {:ping, ^pid, :peer_addr, 0, []}
  end

  test "another peer joined", context do
    {:ok, pid} = start_detector([seeds: [:peer_addr]], context)
    assert :ok == FD.update(pid, :another_peer_addr, {:alive, 0})
    assert [:another_peer_addr, :peer_addr] == FD.members(pid)
  end

  test "messages about self", context do
    {:ok, pid} = start_detector([seeds: [:peer_addr]], context)
    assert :ok == FD.update(pid, :peer_addr, {:alive, 2})
    assert [:peer_addr] == FD.members(pid)
  end

end
