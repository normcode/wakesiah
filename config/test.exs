use Mix.Config

config :wakesiah, :test_remote_name, node() |> Atom.to_string() |> String.replace("foo", "bar") |> String.to_atom()

