defmodule CloudDrive do
    use Application
    use CloudDrive.Database, as: Database
    require Logger

    @server Application.get_env(:cloud_drive, :server)

    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    def start(_type, _args) do
        import Supervisor.Spec, warn: false

        scheme = @server[:scheme]
        port = @server[:port]

        children = [
            # Define workers and child supervisors to be supervised
            Plug.Adapters.Cowboy.child_spec(scheme, CloudDrive.Router, [], [port: port])
        ]

        init_db()

        Task.start(fn ->
            Process.sleep(500)
            Logger.info "Starting local server at #{scheme}://localhost:#{port}"
        end)

        # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
        # for other strategies and supported options
        opts = [strategy: :one_for_one, name: CloudDrive.Supervisor]
        Supervisor.start_link(children, opts)
    end

    def init_db() do
        Amnesia.stop()
        Amnesia.Schema.create()
        Amnesia.start()

        CloudDrive.Database.Tables.create(disk: [node()])
        CloudDrive.Database.Tables.wait()

        if !Database.get(User, email: "ilmari.autio@gmail.com") do
            Database.save(User, %User{email: "ilmari.autio@gmail.com", name: "Ilmari"})
        end
    end
end
