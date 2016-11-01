defmodule CloudDrive do
  use Application

  @server Application.get_env(:cloud_drive, :server)
  @scheme @server[:scheme]
  @port @server[:port]

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      Plug.Adapters.Cowboy.child_spec(
        @scheme, CloudDrive.Router, [], [port: @port])
    ]

    start_js_watcher()

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CloudDrive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp start_js_watcher() do
    Task.start fn ->
      :os.cmd('npm run watch')
    end
  end
end
