# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :prison_rideshare, ecto_repos: [PrisonRideshare.Repo]

# Configures the endpoint
config :prison_rideshare, PrisonRideshareWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Cs7GQrRAb0eRHwFHrArQ14GQFFHTitFITDF8igX3AHoewb8zo2z0/KCteAdK1EIe",
  render_errors: [view: PrisonRideshareWeb.ErrorView, accepts: ~w(json-api)],
  pubsub: [name: PrisonRideshare.PubSub, adapter: Phoenix.PubSub.PG2]

config :prison_rideshare, ui_root: System.get_env("UI_ROOT") || "https://rideshare.barnonewpg.org"

config :prison_rideshare, gas_price_endpoint: System.get_env("GAS_PRICE_ENDPOINT")

config :phoenix, :format_encoders, "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"],
  "text/calendar" => ["ics", "ifb"]
}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :money, default_currency: :CAD, symbol: false

config :prison_rideshare, PrisonRideshare.Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "PrisonRideshare",
  ttl: {365, :days},
  verify_issuer: true,
  secret_key:
    System.get_env("GUARDIAN_SECRET") ||
      "ru/JyaWA1jnKDh8U0KABWzBnDsLR6tHIKOS8C9BOWmd+izwz82zym8AyHWRpRIRy",
  serializer: PrisonRideshare.GuardianSerializer

config :prison_rideshare, PrisonRideshare.PersonGuardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "PrisonRideshare",
  ttl: {365, :days},
  verify_issuer: true,
  secret_key:
    System.get_env("PERSON_GUARDIAN_SECRET") ||
      "kFmeWKr9xPTlCPZdZetQhkKnl1DNc7JgZmAXf5X0SllM71ctO8WDGAiKS5anAOgv",
  token_ttl: %{
    "magic" => {60, :days},
    "access" => {45, :days}
  }

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  root_source_code_path: File.cwd!(),
  included_environments: [:prod],
  environment_name: Mix.env(),
  json_library: Poison

config :paper_trail,
  repo: PrisonRideshare.Repo,
  item_type: :binary_id,
  originator_type: :binary_id

config :prison_rideshare, PrisonRideshare.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: System.get_env("MAILGUN_KEY"),
  domain: "mg.barnonewpg.org"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
