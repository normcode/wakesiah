defmodule Wakesiah do

  use GenServer
  require Logger

  alias Wakesiah.FailureDetector

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
      :exit, {:timeout, _} -> :pang
    end
  end

  def members(pid), do: GenServer.call(pid, :members)

  # Server (callbacks)

  def init({failure_detector}) do
    state = %__MODULE__{failure_detector: failure_detector}
    {:ok, state}
  end

  def handle_call(:members, _from, state) do
    {:reply, FailureDetector.members(state.failure_detector), state}
  end

  def handle_cast(:terminate, state) do
    {:stop, :shutdown, state}
  end

end
