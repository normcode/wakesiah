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
    case status do
      :alive -> HashDict.update(membership, peer_addr, Peer.new(state: :alive, data: inc), &Peer.alive(&1, inc))
      :suspect -> HashDict.update!(membership, peer_addr, &Peer.suspect(&1, inc))
      :failed -> HashDict.update!(membership, peer_addr, &Peer.confirm(&1, inc))
    end
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

end
