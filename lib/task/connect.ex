defmodule Wakesiah.Task.Connect do

  def start_task(name, pid, from) do
    Task.Supervisor.async(:wakesiah_task_sup, __MODULE__, :connect,
                          [name, pid, from])
  end

  def connect(name, peer, from) do
    try do
      {:pong, pid} = GenServer.call(peer, {:ping, name}, 1000)
      {:ok, pid, from}
    catch
      :exit, reason -> {:error, reason}
    end
  end

end
