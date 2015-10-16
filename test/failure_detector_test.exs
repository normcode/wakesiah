defmodule Wakesiah.FailureDetectorTest do

  use ExUnit.Case, async: true

  alias Wakesiah.FailureDetector, as: FD
  alias Wakesiah.FailureDetector.Peer

  setup context do
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
    assert :ok = FD.update(pid, :peer_addr, {:alive, 10}), "alive i > j"
    assert struct(Peer, addr: :peer_addr, status: :alive, incarnation: 10) == FD.peer(pid, :peer_addr)

    assert :ok = FD.update(pid, :peer_addr, {:alive, 9}), "alive i < j"
    assert struct(Peer, addr: :peer_addr, status: :alive, incarnation: 10) == FD.peer(pid, :peer_addr)
    
    assert :ok = FD.update(pid, :peer_addr, {:suspect, 10}), "suspect i >= j"
    assert struct(Peer, addr: :peer_addr, status: :suspect, incarnation: 10) == FD.peer(pid, :peer_addr)

    assert :ok = FD.update(pid, :peer_addr, {:suspect, 20}), "suspect i > j"
    assert struct(Peer, addr: :peer_addr, status: :suspect, incarnation: 20) == FD.peer(pid, :peer_addr)

    assert :ok = FD.update(pid, :peer_addr, {:suspect, 19}), "suspect i < j"
    assert struct(Peer, addr: :peer_addr, status: :suspect, incarnation: 20) == FD.peer(pid, :peer_addr)

    assert :ok = FD.update(pid, :peer_addr, {:alive, 19}), "alive i < j"
    assert struct(Peer, addr: :peer_addr, status: :suspect, incarnation: 20) == FD.peer(pid, :peer_addr)

    assert :ok = FD.update(pid, :peer_addr, {:alive, 21}), "alive i > j"
    assert struct(Peer, addr: :peer_addr, status: :alive, incarnation: 21) == FD.peer(pid, :peer_addr)

    assert :ok = FD.update(pid, :peer_addr, {:suspect, 22}), "suspect i > j"
    assert struct(Peer, addr: :peer_addr, status: :suspect, incarnation: 22) == FD.peer(pid, :peer_addr)
  end

  test "timer tick", context do
    {:ok, pid} = start_detector([seeds: [:peer_addr]], context)
    assert [:peer_addr] == FD.tick(pid)
  end

end
