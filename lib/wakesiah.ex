defmodule Wakesiah do
  use GenServer

  # Client

  def start(name) do
    GenServer.start(__MODULE__, HashDict.new, name: name)
  end
  
  def start_link(name) do
    GenServer.start_link(__MODULE__, HashDict.new, name: name)
  end

  def stop(pid) do
    GenServer.cast(pid, :terminate)
  end

  def inspect(pid) do
    GenServer.call(pid, :inspect)
  end

  def ping_other(pid, other_pid) do
     GenServer.call pid, {:ping_other, other_pid}
  end

  def ping(pid) do
    GenServer.call(pid, :ping)
  end

  # Server (callbacks)

  def init(args) do
    :erlang.send_after 1000, self, :tick
    {:ok, args}
  end

  def handle_call(:inspect, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:ping, {from_pid, _tag}, state) do
    state = HashDict.put(state, from_pid, :ok)
    {:reply, {:pong, self}, state}
  end

  def handle_call({:ping_other, other_pid}, _from, state) do
    {:pong, other_pid} = GenServer.call other_pid, :ping
    {:reply, :pong, HashDict.put(state, other_pid, :ok)}
  end

  def handle_info(:tick, state) do
    :erlang.send_after 1000, self, :tick
    ping_random_pid HashDict.keys(state)
    {:noreply, state}
  end

  def handle_cast(:terminate, state) do
    {:stop, :shutdown, state}
  end

  def ping_random_pid(pids) do
    pids |>
      Enum.shuffle |>
      List.first |>
      ping_pid
  end

  def ping_pid(pid) when is_nil(pid), do: nil
  def ping_pid(pid) do
    IO.puts "pinging random process"
    IO.inspect pid
  end

end
