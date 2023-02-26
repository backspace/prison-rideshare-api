defmodule PrisonRideshare.Mixfile do
  use Mix.Project

  def project do
    [
      app: :prison_rideshare,
      version: "0.0.1",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {PrisonRideshare.Application, []}, extra_applications: [:logger, :phoenix]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_live_view, "~> 0.18"},
      {:phoenix_view, "~> 2.0"},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.3"},
      {:bcrypt_elixir, "~> 3.0"},
      {:cors_plug, "~> 3.0"},
      {:csv, "~> 3.0.5"},
      {:guardian, "~> 2.1"},
      {:guardian_phoenix, "~> 2.0"},
      {:sans_password, "~> 1.1.0"},
      {:ja_serializer, "~> 0.17.0"},
      {:money, "~> 1.12.1"},
      {:timex, "~> 3.7.9"},
      {:bamboo, "~> 2.0"},
      {:bamboo_phoenix, "~> 1.0"},
      {:icalendar, "~> 0.5.0"},
      {:jason, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:paper_trail, "~> 0.14"},
      {:excoveralls, "~> 0.15", only: :test},
      {:faker, "~> 0.17"},
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false},
      {:mock, "~> 0.3.4", only: :test},
      {:sentry, "~> 8.0"},
      {:hackney, "~> 1.8"},
      {:junit_formatter, "~> 3.3", only: [:test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
