defmodule Wakesiah.Membership do

  alias Wakesiah.Peer
  
  def new(seeds \\ []) do
    Enum.into(seeds, HashDict.new, fn peer_addr ->
      {peer_addr, init_peer(peer_addr)}
    end)
  end

  defp init_peer(peer_addr) do
    %Peer{addr: peer_addr, incarnation: 0, status: :alive}
  end

  def from_peers(peers) do
    Enum.into(peers, HashDict.new, fn {peer_addr, peer} ->
      {peer_addr, %Peer{peer | addr: peer_addr}}
    end)
  end

  def update(membership, peer_addr, {status, inc}) do
    HashDict.update!(membership, peer_addr, &maybe_update(&1, {status, inc}))
  end

  def members(membership) do
    Enum.reduce(membership, [], fn
      {_, %Peer{status: :failed}}, acc ->
        acc
      {peer_addr, %Peer{}}, acc ->
        [peer_addr | acc]
    end)
  end

  def get(membership, key), do: Dict.get(membership, key)

  defp maybe_update(peer = %Peer{status: :suspect, incarnation: j}, {:alive, i})
  when i > j do
    %Peer{peer | status: :alive, incarnation: i}
  end

  defp maybe_update(peer = %Peer{status: :alive, incarnation: j}, {:alive, i})
  when i >= j do
    %Peer{peer | incarnation: i}
  end

  defp maybe_update(peer = %Peer{status: :suspect, incarnation: j}, {:suspect, i})
  when i > j do
    %Peer{peer | incarnation: i}
  end

  defp maybe_update(peer = %Peer{status: :alive, incarnation: j}, {:suspect, i})
  when i >= j do
    %Peer{peer | status: :suspect, incarnation: i}
  end

  defp maybe_update(peer = %Peer{}, {:alive, _}), do: peer
  defp maybe_update(peer = %Peer{}, {:suspect, _i}), do: peer

end
