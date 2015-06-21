defmodule Wakesiah do
  use GenServer

  require Logger

  # Client

  def start(opts \\ []) do
    GenServer.start(__MODULE__, :ok, opts)
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
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

  def init(:ok) do
    state = %{members: HashDict.new}
    :erlang.send_after 1000, self, :tick
    {:ok, state}
  end

  def handle_call(:members, _from, state) do
    members = HashDict.keys state[:members]
    {:reply, members, state}
  end

  def handle_cast({:connect, connect_to}, state) do
    Logger.info "Connecting to #{inspect connect_to}"
    {:noreply, state}
  end

  def handle_cast(:terminate, state) do
    {:stop, :shutdown, state}
  end

  def handle_info(:tick, state) do
    :erlang.send_after 1000, self, :tick
    Logger.debug "Firing tick event"
    {:noreply, state}
  end

end
