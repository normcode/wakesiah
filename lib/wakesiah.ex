defmodule Wakesiah do

  use GenServer
  require Logger
  alias Wakesiah.FailureDetector

  @name __MODULE__
  @default_fd_name Wakesiah.FailureDetector

  defstruct [:failure_detector]

  # Client

  def start(opts \\ []) do
    {failure_detector, opts} = Keyword.pop(opts, :failure_detector, @default_fd_name)
    GenServer.start(__MODULE__, {failure_detector}, opts)
  end

  def start_link(opts \\ []) do
    {failure_detector, opts} = Keyword.pop(opts, :failure_detector, @default_fd_name)
    GenServer.start_link(__MODULE__, {failure_detector}, opts)
  end

  def stop(), do: stop(@name)
  def stop(name) do
    GenServer.cast(name, :terminate)
  end

  def ping(peer_id, incarnation, gossip) do
    Logger.debug("Pinging peer: #{inspect peer_id}")
    GenServer.call(peer_id, {:ping, incarnation, gossip}, 100)
  end

  def join(peer_addr) do
    join(@name, {@name, peer_addr})
  end
    
  def join(me_addr, peer_addr) do
    Logger.info("Sending join request #{inspect me_addr} to #{inspect peer_addr}")
    try do
      GenServer.call(peer_addr, {:join, {me_addr, node()}}, 1000)
    catch
      :exit, reason -> {:error, reason}
    end
  end

  def members(), do: members(@name)
  def members(pid), do: GenServer.call(pid, :members)

  # Server (callbacks)

  def init({failure_detector}) do
    state = %__MODULE__{failure_detector: failure_detector}
    {:ok, state}
  end

  def handle_call(:members, _from, state) do
    {:reply, FailureDetector.members(state.failure_detector), state}
  end

  def handle_call({:join, peer_addr}, from, state) do
    Logger.debug("Join #{inspect peer_addr}")
    FailureDetector.update(state.failure_detector, peer_addr, {:alive, 0})
    {:reply, :ok, state}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}

  def handle_cast(:terminate, state) do
    {:stop, :shutdown, state}
  end

end
