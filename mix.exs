defmodule CloudDrive.Mixfile do
    use Mix.Project

    def project do
        [app: :cloud_drive,
        version: "0.0.1",
        elixir: "~> 1.2",
        build_embedded: Mix.env == :prod,
        start_permanent: Mix.env == :prod,
        deps: deps()]
    end

    def application do
        [extra_applications: [:logger, :eex],
        mod: {CloudDrive.Application, []}]
    end

    defp deps do
        [{:plug, "~> 1.2"},
        {:remix, "~> 0.0.2", only: :dev},
        {:amnesia, "~> 0.2.5"},
        {:hashids, "~> 2.0"},
        {:sizeable, "~> 0.1.5"},
        {:timex, "~> 3.1"},
        {:poison, "~> 3.0", override: true},
        {:ueberauth, "~> 0.4"},
        {:ueberauth_google, "~> 0.4"},
        {:httpoison, "~> 0.10.0"},
        {:cowboy, "~> 1.0"},
        {:distillery, "~> 1.4", runtime: false},
        {:webassembly, "~> 0.6"}]
    end
end
