# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

config :cloud_drive, :server,
  host: "localhost",
  port: 8000,
  scheme: :http

config :cloud_drive, :settings,
  shared_files_folder: "user_files/",
  shared_url: "shared"

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [
      default_scope: "email https://www.googleapis.com/auth/drive.readonly",
      access_type: "offline"
    ]}
  ]

# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).

#import_config "#{Mix.env}.exs"
import_config "secret.exs"
