defmodule Wakesiah.Membership do

  alias Wakesiah.Peer
  
  def new(seeds \\ []) do
    Enum.into(seeds, HashDict.new, fn peer_addr ->
      {peer_addr, Peer.new}
    end)
  end

  def from_peers(peers) do
    Enum.into(peers, HashDict.new, fn {peer_addr, peer} ->
      {peer_addr, peer}
    end)
  end

  def update(membership, peer_addr, {status, inc}) do
    HashDict.get_and_update(membership, peer_addr,
                            &do_get_and_update_peer(&1, status, inc))
  end

  def members(membership) do
    Enum.reduce(membership, [], fn
      {_, %Peer{state: :failed}}, acc ->
        acc
      {peer_addr, %Peer{}}, acc ->
        [peer_addr | acc]
    end)
  end

  def random(membership) do
    membership |>
      members |>
      Enum.random
  end

  def get(membership, key), do: Dict.get(membership, key)

  defp do_get_and_update_peer(:nil, status, inc) do
    {:new, Peer.new(state: status, data: inc)}
  end

  defp do_get_and_update_peer(peer = %Peer{}, :alive, inc) do
    Peer.alive(peer, inc)
  end

  defp do_get_and_update_peer(peer = %Peer{}, :suspect, inc) do
    Peer.suspect(peer, inc)
  end

  defp do_get_and_update_peer(peer = %Peer{}, :failed, inc) do
    Peer.failed(peer, inc)
  end

end
