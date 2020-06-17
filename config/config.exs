# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cookie_auth,
  ecto_repos: [CookieAuth.Repo]

# Configures the endpoint
config :cookie_auth, CookieAuthWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "457IgS9E91J4FHhf0Lb+mmOwb2AVhcNOcy2LszXPTCkyHIUuUJXQ0Q7xnCFYY6Zp",
  render_errors: [view: CookieAuthWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CookieAuth.PubSub,
  live_view: [signing_salt: "RMSFh+92"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
