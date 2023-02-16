import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :prison_rideshare, PrisonRideshareWeb.Endpoint,
  http: [port: 4000],
  code_reloader: true,
  check_origin: false,
  watchers: []

# Watch static and templates for browser reloading.
config :prison_rideshare, PrisonRideshareWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/prison_rideshare_web/views/.*(ex)$},
      ~r{lib/prison_rideshare_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :prison_rideshare, PrisonRideshare.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "prison_rideshare_dev",
  hostname: "localhost",
  pool_size: 10

config :prison_rideshare, PrisonRideshare.Mailer, adapter: Bamboo.LocalAdapter

if File.exists?("dev.secret.exs") do
  import_config "dev.secret.exs"
end
