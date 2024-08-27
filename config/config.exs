# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :acc_tournament,
  ecto_repos: [AccTournament.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :acc_tournament, AccTournamentWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AccTournamentWeb.ErrorHTML, json: AccTournamentWeb.ErrorJSON]
  ],
  pubsub_server: AccTournament.PubSub,
  live_view: [signing_salt: "sUS0dTdC"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :acc_tournament, AccTournament.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  acc_tournament: [
    args:
      ~w(js/socket.ts js/app.ts --bundle --splitting --target=es2020 --format=esm --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --analyze),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  acc_tournament: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# config/config.exs
config :acc_tournament, Oban,
  repo: AccTournament.Repo,
  queues: [default: 5]
