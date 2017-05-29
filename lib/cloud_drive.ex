defmodule CloudDrive do
  use Application
  alias CloudDrive.Storage
  require Logger

  @server Application.get_env(:cloud_drive, :server)
  @scheme @server[:scheme]
  @port @server[:port]

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Plug.Adapters.Cowboy.child_spec(
        @scheme, CloudDrive.Router, [], [port: @port]),
      supervisor(Eternal, [:files, [], [quiet: Mix.env == :prod]]),
      supervisor(Eternal, [:users, [], [quiet: Mix.env == :prod]]),
      supervisor(Eternal, [:tags, [], [quiet: Mix.env == :prod]]),
    ]

    opts = [strategy: :one_for_one, name: CloudDrive.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
