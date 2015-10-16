defmodule Wakesiah.FailureDetector do

  use GenServer

  @name __MODULE__

  defmodule State do
    defstruct me: nil, peers: HashDict.new, incarnation: 0
  end
  
  defmodule Peer do
    defstruct addr: nil, status: :alive, incarnation: 0, age: 0
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
    peers = init_peers(seeds)
    {:ok, %State{peers: peers, incarnation: 0}}
  end

  def handle_call({:add_peer, peer_addr}, _from, state) do
    state = [%Peer{addr: peer_addr}]
    {:reply, :ok, state}
  end

  def handle_call(:members, _from, state) do
    members = do_members(state)
    {:reply, members, state}
  end

  def handle_call({:update, peer_addr, status}, _from, state) do
    {response, peers} = do_update(state, peer_addr, status)
    {:reply, response, %State{state|peers: peers}}
  end

  def handle_call({:peer, peer_addr}, _from, %State{peers: peers} = state) do
    peer = Dict.get(peers, peer_addr)
    {:reply, peer, state}
  end

  defp init_peers(seeds) do
    Enum.into(seeds, HashDict.new, fn peer_addr ->
      {peer_addr, %Peer{addr: peer_addr, incarnation: 0}}
    end)
  end
  
  defp do_members(%State{peers: peers}) do
    Dict.keys(peers)
  end

  defp do_update(%State{peers: peers}, peer_addr, status) do
    peers = HashDict.update!(peers, peer_addr, &maybe_update(&1, status))
    {:ok, peers}
  end

  defp maybe_update(peer = %Peer{status: :suspect, incarnation: j},
                    {:alive, i})
  when i > j do
    %Peer{peer | status: :alive, incarnation: i}
  end

  defp maybe_update(peer = %Peer{status: :alive, incarnation: j},
                    {:alive, i})
  when i >= j do
    %Peer{peer | status: :alive, incarnation: i}
  end

  defp maybe_update(peer = %Peer{}, {:alive, _i}), do: peer

  defp maybe_update(peer = %Peer{status: :suspect, incarnation: j},
                    {:suspect, i})
  when i > j do
    %Peer{peer | status: :suspect, incarnation: i}
  end

  defp maybe_update(peer = %Peer{status: :alive, incarnation: j},
                    {:suspect, i})
  when i >= j do
    %Peer{peer | status: :suspect, incarnation: i}
  end

  defp maybe_update(peer = %Peer{}, {:suspect, _i}), do: peer

end
