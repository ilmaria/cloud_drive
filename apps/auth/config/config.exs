use Mix.Config

config :guardian, Guardian,
  issuer: "CloudDriveAuth",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true,
  serializer: Auth.GuardianSerializer,
  secret_key: "0XRJl8331CCnz4y3EPtzazS7S9Qnsuii2OuVy/FssD4yeEYqrEMPJDB3Uu2tF7bO"


import_config "secret.exs"
