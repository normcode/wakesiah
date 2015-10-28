defmodule Wakesiah.BroadcastTest do

  use ExUnit.Case, async: true

  alias Wakesiah.Broadcast

  test "new" do
    assert %Broadcast{} = Broadcast.new
  end

  test "push" do
    broadcast = Broadcast.new |>
      Broadcast.push(join_event(:peer_addr)) |>
      Broadcast.push(join_event(:another_peer))
    assert Broadcast.peek(broadcast) == [join_event(:another_peer),
                                         join_event(:peer_addr)]
  end

  test "pop" do
    events = for x <- 1..10, e = {:joined, x, 0}, do: e
    broadcast = Enum.reduce(events, Broadcast.new, &Broadcast.push(&2, &1))
    assert Broadcast.pop(broadcast) == {events, Broadcast.new}
  end

  def join_event(peer), do: {:joined, peer, 0}

end
