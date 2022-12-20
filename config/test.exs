import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :prison_rideshare, PrisonRideshareWeb.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :prison_rideshare, PrisonRideshare.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  database: System.get_env("POSTGRES_DB") || "prison_rideshare_test",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :prison_rideshare, PrisonRideshare.Mailer, adapter: Bamboo.TestAdapter

defmodule Blacksmith.Config do
  def save(map) do
    PrisonRideshare.Repo.insert(map)
  end

  def save_all(list) do
    Enum.map(list, &PrisonRideshare.Repo.insert/1)
  end
end
