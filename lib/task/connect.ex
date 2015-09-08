defmodule Wakesiah.Task.Connect do

  def start_task(name, pid, from) do
    Task.Supervisor.async(:wakesiah_task_sup, __MODULE__, :connect,
                          [name, pid, from])
  end

  def connect(name, peer, from) do
    case GenServer.call({:wakesiah, name}, {:ping, peer}) do
      {:pong, pid} -> {:ok, pid, from}
    end
  end

end
