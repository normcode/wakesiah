use Mix.Config

config :logger, backends: [:console, {LoggerFileBackend, :info_log}]

config :logger, :info_log, [
  path: "logs/#{Mix.env}.log",
  level: :info,
  format: "\n$date $time [$level] $metadata$message",
]
