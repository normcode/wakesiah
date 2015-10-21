defmodule Wakesiah.FailureDetector do

  use GenServer
  require Logger
  alias Wakesiah.Membership

  @name __MODULE__
  @periodic_ping_timeout 1_000

  defmodule State do
    defstruct [:me, :peers, :incarnation, :timer, :tasks]
  end

  def start_link(options \\ [name: @name]) do
    {seeds, options} = Keyword.pop(options, :seeds, [])
    GenServer.start_link(__MODULE__, seeds, options)
  end

  def members(pid \\ @name) do
    GenServer.call(pid, :members)
  end

  def update(peer_id, new_status), do: update(@name, peer_id, new_status)
  def update(pid, peer_id, new_status) do
    GenServer.call(pid, {:update, peer_id, new_status})
  end

  def peer(peer_id), do: peer(@name, peer_id)
  def peer(pid, peer_id) do
    GenServer.call(pid, {:peer, peer_id})
  end

  def init(seeds) when is_list(seeds) do
    peers = Membership.new(seeds)
    timer = :timer.send_after(@periodic_ping_timeout, :tick)
    {:ok, %State{peers: peers, incarnation: 0, timer: timer, tasks: []}}
  end

  def handle_call(:members, _from, state = %State{}) do
    members = Membership.members(state.peers)
    {:reply, members, state}
  end

  def handle_call({:update, peer_id, {event, inc}}, _from, state = %State{}) do
    Logger.debug("Updating: #{inspect peer_id} #{inspect {event, inc}}")
    peers = Membership.update(state.peers, peer_id, {event, inc})
    Logger.debug("Peers: #{inspect peers}")
    {:reply, :ok, %State{state | peers: peers}}
  end

  def handle_call({:peer, peer_addr}, _from, %State{peers: peers} = state) do
    peer = Membership.get(peers, peer_addr)
    {:reply, peer, state}
  end

  def handle_call({:ping, _i}, _from, state) do
    {:reply, {:ack, state.incarnation}, state}
  end

  def handle_info(:tick, state = %State{incarnation: seq_num}) do
    Logger.debug("Handling :tick #{inspect state}")
    if Enum.empty?(state.peers) do
      timer = :timer.send_after(@periodic_ping_timeout, :tick)
      {:noreply, %State{state | timer: timer, incarnation: seq_num + 1}}
    else
      peer_addr = Membership.random(state.peers)
      task = tasks.ping(self, peer_addr, seq_num)
      tasks = [task | state.tasks]
      timer = :timer.send_after(@periodic_ping_timeout, :tick)
      {:noreply, %State{state | timer: timer, tasks: tasks, incarnation: seq_num + 1}}
    end      
  end

  def handle_info(msg = {ref, _}, state = %State{}) when is_reference(ref) do
    case Task.find(state.tasks, msg) do
      {resp, task} when resp in [:ack, :ok] -> # XXX
        Logger.debug("Task #{inspect task} returned: #{inspect resp}")
        {:noreply, %State{state | tasks: List.delete(state.tasks, task)}}
      {:pang, task} ->
        Logger.debug("Task #{inspect task} returned: :pang")
        {:noreply, %State{state | tasks: List.delete(state.tasks, task)}}
    end
  end

  defp tasks() do
    Application.get_env(:wakesiah, :task_mod, Wakesiah.Tasks)
  end

end
