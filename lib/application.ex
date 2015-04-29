defmodule WakesiahApp do
  use Application

  def start(_type, _args) do
    IO.puts "Starting Wakesiah Application"
    :random.seed(:os.timestamp)
    # TODO: should set up supervisor
    name = Application.get_env(:wakesiah, :registration, :wakesiah)
    Wakesiah.start_link(name: name)
  end
end
