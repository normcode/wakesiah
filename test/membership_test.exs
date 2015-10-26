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
    membership = init_membership(peer_addr: [state: :alive, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:alive, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :alive, data: inc + 1)
  end

  test "update :alive, :suspect, i > j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :alive, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:suspect, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :suspect, data: inc + 1)
  end

  test "update :alive, :failed, i > j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :alive, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:failed, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc + 1)
  end

  test "update :alive, :alive, i == j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :alive, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:alive, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :alive, data: inc + 1)
  end

  test "update :alive, :suspect, i == j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :alive, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:suspect, inc})
    assert_peer membership, :peer_addr, Peer.new(state: :suspect, data: inc)
  end

  test "update :alive, :failed, i == j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :alive, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:failed, inc})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "update :alive, :alive, i < j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :alive, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:alive, inc - 1})
    assert_peer membership, :peer_addr, Peer.new(state: :alive, data: inc)
  end

  test "update :alive, :suspect, i < j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :alive, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:suspect, inc - 1})
    assert_peer membership, :peer_addr, Peer.new(state: :alive, data: inc)
  end

  test "update :alive, :failed, i < j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :alive, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:failed, inc - 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc - 1)
  end

  # suspect

  test "state: :suspect, :alive, i > j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :suspect, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:alive, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :alive, data: inc + 1)
  end

  test "update :suspect, :suspect, i > j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :suspect, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:suspect, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :suspect, data: inc + 1)
  end

  test "update :suspect, :failed, i > j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :suspect, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:failed, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc + 1)
  end

  test "update :suspect, :alive, i == j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :suspect, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:alive, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :alive, data: inc + 1)
  end

  test "update :suspect, :suspect, i == j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :suspect, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:suspect, inc})
    assert_peer membership, :peer_addr, Peer.new(state: :suspect, data: inc)
  end

  test "update :suspect, :failed, i == j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :suspect, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:failed, inc})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "update :suspect, :alive, i < j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :suspect, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:alive, inc - 1})
    assert_peer membership, :peer_addr, Peer.new(state: :suspect, data: inc)
  end

  test "update :suspect, :suspect, i < j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :suspect, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:suspect, inc - 1})
    assert_peer membership, :peer_addr, Peer.new(state: :suspect, data: inc)
  end

  test "update :suspect, :failed, i < j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :suspect, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:failed, inc - 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc - 1)
  end

  # failed

  test "state: :failed, :alive, i > j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :failed, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:alive, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "update :failed, :suspect, i > j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :failed, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:suspect, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "update :failed, :failed, i > j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :failed, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:failed, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "update :failed, :alive, i == j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :failed, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:alive, inc + 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "update :failed, :suspect, i == j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :failed, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:suspect, inc})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "update :failed, :failed, i == j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :failed, data: inc])
    assert {_, membership} = Membership.update(membership, :peer_addr, {:failed, inc})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "update :failed, :alive, i < j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :failed, data: inc])
    assert assert {_, membership} = Membership.update(membership, :peer_addr, {:alive, inc - 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "update :failed, :suspect, i < j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :failed, data: inc])
    assert assert {_, membership} = Membership.update(membership, :peer_addr, {:suspect, inc - 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "update :failed, :failed, i < j", %{inc: inc} do
    membership = init_membership(peer_addr: [state: :failed, data: inc])
    assert assert {_, membership} = Membership.update(membership, :peer_addr, {:failed, inc - 1})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: inc)
  end

  test "add :alive peer" do
    membership = init_membership([])
    assert {:new, membership} = Membership.update(membership, :peer_addr, {:alive, 0})
    assert_peer membership, :peer_addr, Peer.new(state: :alive, data: 0)
  end

  test "add :suspect peer" do
    membership = init_membership([])
    assert {:new, membership} = Membership.update(membership, :peer_addr, {:suspect, 0})
    assert_peer membership, :peer_addr, Peer.new(state: :suspect, data: 0)
  end

  test "add :failed peer" do
    membership = init_membership([])
    assert {:new, membership} = Membership.update(membership, :peer_addr, {:failed, 0})
    assert_peer membership, :peer_addr, Peer.new(state: :failed, data: 0)
  end

end
