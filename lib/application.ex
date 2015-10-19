defmodule WakesiahApp do
  use Application

  def start(_type, _args) do
    Wakesiah.Supervisor.start_link()
  end

end
