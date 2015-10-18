defmodule Wakesiah.FailureDetectorTest do

  use ExUnit.Case, async: true

  alias Wakesiah.FailureDetector, as: FD

  setup context do
    Test.PingSelf.register_test
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
  end

  test "receiver timer", context do
    Application.put_env(:wakesiah, :wakesiah_mod, Test.PingSelf)
    {:ok, pid} = start_detector([], context)
    send(pid, :tick)
    assert_receive :ping
  end

end
