defmodule Wakesiah do
  use GenServer

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

  # Server (callbacks)

  def init(args) do
    state = %{members: HashDict.new, events: args}
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
