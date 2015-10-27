use Mix.Config

config :wakesiah, :test_remote_name, (
  node() |> Atom.to_string() |> String.replace("foo", "bar")
  |> String.to_atom()
)

config :logger, :console, format: "$time $metadata[$level] $levelpad $message\n"
config :logger, [backends: [:console], level: :debug]
