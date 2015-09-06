defmodule Wakesiah.Task.Connect do

  def start_task(task_sup, pid, from) do
    Task.Supervisor.async(task_sup, __MODULE__, :ping_other,
                          [:wakesiah, pid, from])
  end

  def ping_other(pid, peer, from) do
    case GenServer.call(pid, {:ping, peer}) do
      {:pong, pid} -> {:ok, pid, from}
    end
  end

end
