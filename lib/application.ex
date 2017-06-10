defmodule CloudDrive.Application do
    use Application
    use Amnesia
    use CloudDrive.Database
    require Logger

    @server Application.get_env(:cloud_drive, :server)

    def start(_type, _args) do
        import Supervisor.Spec, warn: false

        scheme = @server[:scheme]
        port = @server[:port]

        init_db()

        children = [
            Plug.Adapters.Cowboy.child_spec(scheme, CloudDrive.Router, [], [port: port]),
            worker(CloudDrive.GoogleSyncServer, []),
        ]

        Task.start(fn ->
            Process.sleep(500)
            Logger.info "Starting local server at #{scheme}://localhost:#{port}"
        end)

        opts = [strategy: :one_for_one, name: CloudDrive.Supervisor]
        Supervisor.start_link(children, opts)
    end

    def init_db() do
        Amnesia.stop()
        Logger.debug "Create schema: " <> inspect Amnesia.Schema.create()
        Amnesia.start()

        Logger.debug "Create database: " <> inspect CloudDrive.Database.create(disk: [node()])
        CloudDrive.Database.wait()

        Amnesia.transaction do
            if User.match(email: "ilmari.autio@gmail.com") == nil do
                %User{email: "ilmari.autio@gmail.com"} |> User.write()
            end
        end
    end
end
