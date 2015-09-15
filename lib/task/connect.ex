defmodule Wakesiah.Task.Connect do

  require Logger

  def start_task(name, pid, from) do
    Task.Supervisor.async(:wakesiah_task_sup, __MODULE__, :connect,
                          [name, pid, from])
  end

  def connect(name, peer, from) do
    try do
      Logger.debug("Pinging peer #{inspect peer} from #{inspect name}")
      {:pong, pid} = GenServer.call(peer, {:ping, name}, 1000)
      Logger.debug("Pong from #{inspect peer}")
      {:ok, pid, from}
    catch
      :exit, reason ->
        Logger.debug("Pang from #{inspect peer}, error: #{inspect {:exit, reason}}")
        {:error, reason}
    end
  end

end
