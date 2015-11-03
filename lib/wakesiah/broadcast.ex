defmodule Wakesiah.Broadcast do

  defstruct waiting: []

  def new(), do: %__MODULE__{}

  def push(broadcast, event) do
    %__MODULE__{broadcast | waiting: [{event, 0} | broadcast.waiting]}
  end

  def peek(broadcast) do
    broadcast.waiting
    |> Enum.sort
    |> Enum.map(fn {event, _count} -> event end)
  end

  def pop(broadcast) do
    # TODO handle max gossip size and encoding
    {peek(broadcast), %__MODULE__{}}
  end

end
