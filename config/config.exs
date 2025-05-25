# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :payment_server, PaymentServer.Repo,
  database: "payment_server_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :payment_server,
  ecto_repos: [PaymentServer.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :payment_server, PaymentServerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: PaymentServerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PaymentServer.PubSub,
  live_view: [signing_salt: "FSJSYur+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use EctoShorts for easy filtering and preloading
config :ecto_shorts,
  repo: PaymentServer.Repo,
  error_module: EctoShorts.Actions.Error

# Import supported currencies
import_config "currencies.exs"
import_config "exchange_rate_monitor.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
