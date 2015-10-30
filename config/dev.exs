use Mix.Config

config :logger, :console, format: "$time $metadata[$level] $levelpad $message\n", level: :debug
config :logger, [backends: [:console], level: :info]
