defmodule WakesiahApp do
  use Application

  def start(_type, _args) do
    worker_name = Application.get_env(:wakesiah, :registration, :wakesiah)
    Wakesiah.Supervisor.start_link(worker_name: worker_name)
  end

end
