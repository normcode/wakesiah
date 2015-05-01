defmodule Wakesiah do
  use GenServer

  # Client

  def start(opts \\ []) do
    state = %{members: HashDict.new}
    GenServer.start(__MODULE__, state , opts)
  end

  def start_link(opts \\ []) do
    state = %{members: HashDict.new}
    GenServer.start_link(__MODULE__, state, opts)
  end
  
  def stop(pid) do
    GenServer.cast(pid, :terminate)
  end

  def members(pid) do
    GenServer.call(pid, :members)
  end

  # Server (callbacks)

  def init(args) do
    :erlang.send_after 1000, self, :tick
    {:ok, args}
  end

  def handle_call(:members, _from, state) do
    members = HashDict.keys state[:members]
    {:reply, members, state}
  end

  def handle_info(:tick, state) do
    :erlang.send_after 1000, self, :tick
    {:noreply, state}
  end

  def handle_cast(:terminate, state) do
    {:stop, :shutdown, state}
  end

end
