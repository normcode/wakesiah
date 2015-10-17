defmodule Wakesiah.FailureDetector do

  use GenServer

  alias Wakesiah.Membership

  @name __MODULE__

  defmodule State do
    defstruct [:me, :peers, :incarnation]
  end

  def start_link(options \\ [name: @name])
  def start_link(options) do
    {seeds, options} = Keyword.pop(options, :seeds, [])
    GenServer.start_link(__MODULE__, seeds, options)
  end

  def add(peer_addr), do: add(@name, peer_addr)
  def add(pid, peer_addr) do
    GenServer.call(pid,  {:add_peer, peer_addr})
  end

  def members(pid \\ @name) do
    GenServer.call(pid, :members)
  end

  def update(peer_id, new_status), do: update(@name, peer_id, new_status)
  def update(pid, peer_id, new_status) when is_pid(pid) do
    GenServer.call(pid, {:update, peer_id, new_status})
  end

  def peer(peer_id), do: peer(@name, peer_id)
  def peer(pid, peer_id) do
    GenServer.call(pid, {:peer, peer_id})
  end
  
  def init(seeds) when is_list(seeds) do
    peers = Membership.new(seeds)
    {:ok, %State{peers: peers, incarnation: 0}}
  end

  def handle_call(:members, _from, state = %State{}) do
    members = Membership.members(state.peers)
    {:reply, members, state}
  end

  def handle_call({:update, peer_id, {event, inc}}, _from, state = %State{}) do
    peers = Membership.update(state.peers, peer_id, {event, inc})
    {:reply, :ok, %State{state | peers: peers}}
  end

  def handle_call({:peer, peer_addr}, _from, %State{peers: peers} = state) do
    peer = Dict.get(peers, peer_addr)
    {:reply, peer, state}
  end

end
