use Mix.Config

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

import_config "secret.exs"
