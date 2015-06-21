defmodule Wakesiah do
  use GenServer

  require Logger

  # Client

  def start(event_manager, opts \\ []) do
    GenServer.start(__MODULE__, event_manager, opts)
  end

  def start_link(event_manager, opts \\ []) do
    GenServer.start_link(__MODULE__, event_manager, opts)
  end

  def stop(pid) do
    GenServer.cast(pid, :terminate)
  end

  def members(pid) do
    GenServer.call(pid, :members)
  end

  def connect(pid, connect_to) do
    GenServer.cast(pid, {:connect, connect_to})
  end

  # Server (callbacks)

  def init(event_manager_name)
  when not is_nil(event_manager_name)
  and is_atom(event_manager_name) do
    event_manager = Process.whereis(event_manager_name)
    init(event_manager)
  end
  
  def init(event_manager) do
    state = %{members: HashDict.new, events: event_manager}
    :erlang.send_after 1000, self, :tick
    {:ok, state}
  end

  def handle_call(:members, _from, state) do
    members = HashDict.keys state[:members]
    {:reply, members, state}
  end

  def handle_info(:tick, state) do
    :erlang.send_after 1000, self, :tick
    GenEvent.sync_notify state[:events], :tick
    {:noreply, state}
  end

  def handle_cast(:terminate, state) do
    {:stop, :shutdown, state}
  end

end
