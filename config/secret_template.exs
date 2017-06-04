use Mix.Config

config :cloud_drive, :secret,
    hashids_salt: "",
    secret_key_base: ""

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
    client_id: "",
    client_secret: ""

