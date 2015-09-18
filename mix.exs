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
     applications: [:logger] ++ env_apps]
  end

  defp env_apps do
    case Mix.env do
      :dev -> [:dbg]
      _ -> []
    end
  end
  
  defp deps do
    [
      {:dbg, github: "fishcakez/dbg", only: [:dev]},
      {:logger_file_backend, "~> 0.0.4", only: [:dev, :test]},
      {:exrm, "~> 0.19.5"},
    ]
  end
end
