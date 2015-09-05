use Mix.Config

config :logger, :console, level: :info,
  format: "$date $time [$level] $message\n"

case Mix.env do
  :test ->
    import_config "#{Mix.env}.exs"
  _ -> nil
end
