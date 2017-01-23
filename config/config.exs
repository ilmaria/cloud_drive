# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :cloud_drive,
  ecto_repos: [Storage.Repo]

config :cloud_drive, Storage.Repo,
  adapter: Ecto.Adapters.Mnesia

# Configures the endpoint
config :cloud_drive, CloudDrive.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tOgdG9WopS6SJZjNZyfugVNuos5U5btlwDwqefF7+AMDk9bL87N8fB8ocirkSOAl",
  render_errors: [view: CloudDrive.ErrorView, accepts: ~w(html json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  issuer: "CloudDriveAuth",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true,
  serializer: Auth.GuardianSerializer

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [
      default_scope: "email https://www.googleapis.com/auth/drive.readonly",
      access_type: "offline"
    ]}]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
