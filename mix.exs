defmodule Wakesiah.Mixfile do
  use Mix.Project

  def project do
    [app: :wakesiah,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [mod: {WakesiahApp, []},
     applications: [:logger]]
  end

  defp deps do
    [
      {:logger_file_backend, "~> 0.0.4", only: :test},
    ]
  end
end
