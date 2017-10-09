use Mix.Config

# FIXME the host needs to be configurable, obvs
config :prison_rideshare, PrisonRideshareWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  check_origin: ["https://prison-rideshare-sandbox.herokuapp.com"],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info

config :prison_rideshare, PrisonRideshare.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true
