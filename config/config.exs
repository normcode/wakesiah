use Mix.Config

config :logger, :console, level: :info,
  format: "$date $time [$level] $message\n"

if Path.join(["config", "#{Mix.env}.exs"]) |> File.exists? do
  import_config "#{Mix.env}.exs"
end
