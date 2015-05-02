defmodule WakesiahTest do
  use ExUnit.Case, async: true

  defmodule EventHandler do
    use GenEvent

    def init(parent) do
      {:ok, parent}
    end

    def handle_event(event, parent) do
      send parent, {:event, event}
      {:ok, parent}
    end
  end

  setup do
    {:ok, event_manager} = GenEvent.start_link
    :ok = GenEvent.add_mon_handler event_manager, EventHandler, self
    {:ok, pid} = Wakesiah.start_link event_manager

    on_exit fn ->
      Wakesiah.stop pid
      Wakesiah.stop event_manager
    end

    {:ok, [pid: pid, event_manager: event_manager]}
  end

  test "membership list is empty on start", %{pid: pid} do
    assert Wakesiah.members(pid) == []
  end

  test "tick sends tick event", %{pid: pid} do
    send pid, :tick
    assert_receive {:event, :tick}, 1_000
  end

end
