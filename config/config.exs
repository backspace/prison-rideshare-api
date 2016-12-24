# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :prison_rideshare,
  ecto_repos: [PrisonRideshare.Repo]

# Configures the endpoint
config :prison_rideshare, PrisonRideshare.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Cs7GQrRAb0eRHwFHrArQ14GQFFHTitFITDF8igX3AHoewb8zo2z0/KCteAdK1EIe",
  render_errors: [view: PrisonRideshare.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PrisonRideshare.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: PrisonRideshare.User,
  repo: PrisonRideshare.Repo,
  module: PrisonRideshare,
  logged_out_url: "/",
  email_from_name: "Name to come",
  email_from_email: "b@chromatin.ca",
  opts: [:invitable, :confirmable, :authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :registerable, :rememberable],
  rememberable_cookie_expire_hours: 365*24

config :coherence, PrisonRideshare.Coherence.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  domain: "mg.chromatin.ca"
# %% End Coherence Configuration %%

config :money, default_currency: :CAD, symbol: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
