use Mix.Config

config :wakesiah, :test_remote_name, (
  node() |> Atom.to_string() |> String.replace("foo", "bar")
  |> String.to_atom()
)

config :logger, backends: [{LoggerFileBackend, :debug_log}]

config :logger, :debug_log, [
  path: "logs/#{Mix.env}.log",
  level: :debug
]
