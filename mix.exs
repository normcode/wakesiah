defmodule Wakesiah.Mixfile do
  use Mix.Project

  def project do
    [app: :wakesiah,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    []
    # [mod: {WakesiahApp, []},
    #  env: [registration: :wakesiah],
    #  applications: [:logger]]
  end

  defp deps do
    []
  end
end
