defmodule Wakesiah.MembershipTest do

  use ExUnit.Case, async: true

  alias Wakesiah.Membership
  alias Wakesiah.Membership.Peer

  test "new" do
    membership = Membership.new
    assert Enum.empty?(membership)
  end

  def init_membership(peers), do: init_membership(peers, HashDict.new)
  def init_membership([], acc),  do: acc
  def init_membership([{peer_addr, attrs} | t], acc) do
    peer = struct(Peer, Dict.put(attrs, :addr, peer_addr))
    init_membership(t, HashDict.put(acc, peer_addr, peer))
  end

  def assert_members(membership, peer_addrs) do
    assert (membership |>
      Membership.members() |>
      Enum.sort) == peer_addrs
  end

  def assert_peer(membership, peer = %Peer{addr: peer_addr}) do
    assert (membership |> Membership.get(peer_addr)) == peer
  end
  
  test "members excludes failed peers" do
    membership = init_membership(peer_addr: [status: :failed, incaranation: 0],
                                 alive_addr: [status: :alive, incarnation: 0],
                                 suspect_addr: [status: :suspect, incarnation: 0])
    assert_members membership, [:alive_addr, :suspect_addr]
  end

  test "state: :alive, :alive, i > j" do
    init_membership(peer_addr: [status: :alive]) |>
      Membership.update(:peer_addr, {:alive, 1}) |>
      assert_peer %Peer{status: :alive, addr: :peer_addr, incarnation: 1}
  end

  test "update :alive, :suspect, i > j" do
    init_membership(peer_addr: [status: :alive]) |>
      Membership.update(:peer_addr, {:suspect, 1}) |>
      assert_peer %Peer{status: :suspect, addr: :peer_addr, incarnation: 1}
  end

  test "update :alive, :alive, i == j" do
    init_membership(peer_addr: [status: :alive]) |>
      Membership.update(:peer_addr, {:alive, 1}) |>
      assert_peer %Peer{status: :alive, addr: :peer_addr, incarnation: 1}
  end

  test "update :alive, :suspect, i == j" do
    init_membership(peer_addr: [status: :alive]) |>
      Membership.update(:peer_addr, {:suspect, 1}) |>
      assert_peer %Peer{status: :suspect, addr: :peer_addr, incarnation: 1}
  end

  test "update :alive, :alive, i < j" do
    init_membership(peer_addr: [status: :alive, incarnation: 2]) |>
      Membership.update(:peer_addr, {:alive, 1}) |>
      assert_peer %Peer{status: :alive, addr: :peer_addr, incarnation: 2}
  end

  test "update :suspect, :alive, i < j" do
    init_membership(peer_addr: [status: :suspect, incarnation: 2]) |>
      Membership.update(:peer_addr, {:suspect, 1}) |>
      assert_peer %Peer{status: :suspect, addr: :peer_addr, incarnation: 2}
  end

end
