defmodule Wakesiah.MembershipTest do

  use ExUnit.Case, async: true

  alias Wakesiah.Membership
  alias Wakesiah.Peer

  def init_membership(peers), do: init_membership(peers, HashDict.new)
  def init_membership([], acc),  do: acc
  def init_membership([{peer_addr, attrs} | t], acc) do
    peer = Peer.new(attrs)
    init_membership(t, HashDict.put(acc, peer_addr, peer))
  end

  def assert_members(membership, peer_addrs) do
    assert (membership |>
      Membership.members() |>
      Enum.sort) == peer_addrs
  end

  def assert_peer(membership, peer_addr, peer) do
    other_peer = Membership.get(membership, peer_addr)
    assert other_peer == peer
  end

  setup do
    {:ok, [inc: Enum.random 10..100]}
  end
  
  test "new" do
    membership = Membership.new
    assert Enum.empty?(membership)
  end

  test "members excludes failed peers" do
    membership = init_membership(peer_addr: [state: :failed],
                                 alive_addr: [state: :alive],
                                 suspect_addr: [state: :suspect])
    assert_members membership, [:alive_addr, :suspect_addr]
  end

  test "state: :alive, :alive, i > j", %{inc: inc} do
    init_membership(peer_addr: [state: :alive, data: inc]) |>
      Membership.update(:peer_addr, {:alive, inc + 1}) |>
      assert_peer :peer_addr, Peer.new(state: :alive, data: inc + 1)
  end

  test "update :alive, :suspect, i > j", %{inc: inc} do
    init_membership(peer_addr: [state: :alive, data: inc]) |>
      Membership.update(:peer_addr, {:suspect, inc + 1}) |>
      assert_peer :peer_addr, Peer.new(state: :suspect, data: inc + 1)
  end

  test "update :alive, :alive, i == j", %{inc: inc} do
    init_membership(peer_addr: [state: :alive, data: inc]) |>
      Membership.update(:peer_addr, {:alive, inc + 1}) |>
      assert_peer :peer_addr, Peer.new(state: :alive, data: inc + 1)
  end

  test "update :alive, :suspect, i == j", %{inc: inc} do
    init_membership(peer_addr: [state: :alive, data: inc]) |>
      Membership.update(:peer_addr, {:suspect, inc}) |>
      assert_peer :peer_addr, Peer.new(state: :suspect, data: inc)
  end

  test "update :alive, :alive, i < j", %{inc: inc} do
    init_membership(peer_addr: [state: :alive, data: inc]) |>
      Membership.update(:peer_addr, {:alive, inc - 1}) |>
      assert_peer :peer_addr, Peer.new(state: :alive, data: inc)
  end

  test "update :suspect, :alive, i < j", %{inc: inc} do
    init_membership(peer_addr: [state: :suspect, data: inc]) |>
      Membership.update(:peer_addr, {:suspect, inc - 1}) |>
      assert_peer :peer_addr, Peer.new(state: :suspect, data: inc)
  end

end
