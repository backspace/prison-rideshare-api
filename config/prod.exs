use Mix.Config

config :prison_rideshare, PrisonRideshare.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "prison-rideshare.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info

config :prison_rideshare, PrisonRideshare.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :coherence, PrisonRideshare.Coherence.Mailer,
  api_key: System.get_env("MAILGUN_KEY")
