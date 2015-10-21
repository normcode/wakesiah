defmodule Wakesiah do

  use GenServer
  require Logger
  alias Wakesiah.FailureDetector

  @name :wakesiah
  defstruct [:failure_detector]

  # Client

  def start(opts \\ []) do
    {failure_detector, options} = Keyword.pop(opts, :failure_detector, :wakesiah_failure_detector)
    GenServer.start(__MODULE__, {failure_detector}, opts)
  end

  def start_link(opts \\ []) do
    {failure_detector, options} = Keyword.pop(opts, :failure_detector, :wakesiah_failure_detector)
    GenServer.start_link(__MODULE__, {failure_detector}, opts)
  end

  def stop(), do: stop(:wakesiah)
  def stop(pid) do
    GenServer.cast(pid, :terminate)
  end

  def ping(peer_id, seq_num) do
    try do
      GenServer.call(peer_id, {:ping, seq_num}, 100)
    catch
      :exit, reason -> :pang
    end
  end

  def join(peer_addr), do: join(@name, @name, peer_addr)
  def join(me_addr, peer_addr), do: join(@name, me_addr, peer_addr)
  def join(pid, me_addr, peer_addr) do
    Logger.debug("Sending join request to #{inspect peer_addr}")
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
    GenServer.reply(from, :ok)
    broadcast_join(peer_addr, state)
    {:noreply, FailureDetector.update(state.failure_detector, peer_addr, {:alive, 0}), state}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}

  def handle_cast(:terminate, state) do
    {:stop, :shutdown, state}
  end

  def broadcast_join(peer_addr, %__MODULE__{failure_detector: fd}) do
    for peer <- Enum.into([peer_addr], FailureDetector.members(fd)) do
      GenServer.cast(peer, {:joined, peer_addr})
    end
  end

end
