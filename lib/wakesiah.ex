defmodule Wakesiah do

  defmodule Member do
    defstruct pid: nil, status: nil, monitor_ref: nil
  end

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

  def members(), do: members(:wakesiah)
  def members(pid) do
    GenServer.call(pid, :members)
  end

  def connect(connect_to), do: connect(:wakesiah, connect_to)
  def connect(pid, connect_to) do
    try do
      GenServer.call(pid, {:connect, connect_to}, 1000)
    catch
      :exit, {:timeout, _} -> {:error, :timeout}
    end
  end

  # Server (callbacks)

  def init(:ok) do
    state = %{members: HashDict.new, tasks: HashSet.new}
    :erlang.send_after(1000, self, :tick)
    {:ok, state}
  end

  def handle_call(:members, _from, state) do
    members = Dict.values(state.members)
    {:reply, members, state}
  end

  def handle_call({:connect, node_name}, from, state) when is_atom(node_name) do
    Logger.info("Connecting from: #{inspect self()} to: #{inspect node_name}")
    connect_task = Wakesiah.Task.Connect.start_task(self(), {:wakesiah, node_name}, from)
    state = %{state | tasks: [connect_task] |> Enum.into(state.tasks)}
    {:noreply, state}
  end

  def handle_call({:connect, pid}, from, state) when is_pid(pid) do
    Logger.info("Connecting from: #{inspect self()} to: #{inspect pid}")
    connect_task = Wakesiah.Task.Connect.start_task(self(), pid, from)
    state = %{state | tasks: [connect_task] |> Enum.into(state.tasks)}
    {:noreply, state}
  end

  def handle_call({:ping, peer}, _from, state) do
    Logger.info("Adding peer self: #{inspect self()} peer: #{inspect peer}")
    members = add_new_member(state.members, peer)
    {:reply, {:pong, self}, %{state | members: members}}
  end

  def handle_info(:tick, state) do
    :erlang.send_after(5000, self, :tick)
    Logger.debug("Firing tick event")
    {:noreply, state}
  end

  def handle_info(msg = {ref, _}, state) when is_reference(ref) do
    case Task.find(state.tasks, msg) do
      {{:ok, pid, from}, task} ->
        members = add_new_member(state.members, pid)
        tasks = Set.delete(state.tasks, task)
        response = {:ok, :connected}
        GenServer.reply(from, response)
        {:noreply, %{state | members: members, tasks: tasks}}
      {{:error, {reason, _ }}, %Task{}} ->
        Logger.info("Peer down: #{inspect reason}")
        {:noreply, state}
    end
  end

  def handle_info({:DOWN, monitor_ref, :process, pid, reason}, state) do
    Logger.info("Process down: #{inspect pid} reason: #{inspect reason} #{inspect state.members}")
    case Dict.pop(state.members, pid) do
      {%{pid: ^pid, monitor_ref: ^monitor_ref}, members} ->
        Process.demonitor(monitor_ref)
        {:noreply, %{state | members: members}}
    end
  end

  def handle_cast(:terminate, state) do
    {:stop, :shutdown, state}
  end

  defp add_new_member(members, pid) do
    case Dict.fetch(members, pid) do
      {:ok, _} -> members
      :error ->
        ref = Process.monitor(pid)
        member = %Member{pid: pid, status: :ok, monitor_ref: ref}
        Dict.put(members, pid, member)
    end
  end


end
