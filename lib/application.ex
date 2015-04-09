defmodule WakesiahApp do
  use Application

  def start(_type, _args) do
    IO.puts "Starting Wakesiah Application"
    :random.seed(:os.timestamp)
    # TODO: should set up supervisor
    # By default, register locally using a well known name
    Application.get_env(:wakesiah, :registration, :wakesiah) |>
      Wakesiah.start_link
  end
end
