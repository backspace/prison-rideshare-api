import Config

config :prison_rideshare, PrisonRideshareWeb.Endpoint,
  http: [port: System.get_env("PORT"), compress: true],
  check_origin: false,
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info

config :prison_rideshare, PrisonRideshare.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  # `ssl: true` used to mean "encrypt, don't verify". Since postgrex 0.18 it
  # also verifies against the system CA store, which the dokku postgres link
  # can never satisfy: it presents a self-signed cert on the host's private
  # docker network, where no public CA applies. Keep the encryption, drop the
  # verification, as before.
  ssl: [verify: :verify_none]

config :prison_rideshare, PrisonRideshare.Mailer,
  deliver_later_strategy: PrisonRideshare.MailerRateLimiter,
  rate_limit_ms: String.to_integer(System.get_env("MAILER_RATE_LIMIT_MS") || "30000")

config :prison_rideshare, gas_price_endpoint: System.get_env("GAS_PRICE_ENDPOINT")
