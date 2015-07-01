defmodule Wakesiah.Supervisor do
  use Supervisor

  @default_worker_name :wakesiah

  def start_link(opts \\ []) do
    {worker_name, opts} = Keyword.pop(opts, :worker_name, @default_worker_name)
    Supervisor.start_link(__MODULE__, worker_name, opts)
  end

  def init(worker_name) do
    children = [
      worker(Wakesiah, [[name: worker_name]]),
    ]

    supervise(children, strategy: :one_for_one)
  end

end
