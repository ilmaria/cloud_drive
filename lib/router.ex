defmodule CloudDrive.Router do
    use Plug.Router
    alias CloudDrive.Views
    require Logger

    if Mix.env == :dev do
        use Plug.Debugger, otp_app: :cloud_drive
    end

    @secrets Application.get_env(:cloud_drive, :secret)

    plug Plug.Logger
    plug Plug.Static,
        at: "/static",
        from: {:cloud_drive, "priv/static"}
    plug Plug.Parsers,
        parsers: [:multipart, :json],
        pass: ["*/*"],
        json_decoder: Poison
    plug :put_secret_key_base
    plug Plug.Session,
        store: :cookie,
        key: "_cloud_drive_session",
        encryption_salt: "cookie store encryption salt",
        signing_salt: "cookie store signing salt",
        key_length: 64,
        log: :debug
    plug :fetch_session
    plug Ueberauth
    plug :match
    plug :dispatch

    forward "/file", to: Views.FileHandler
    forward "/auth", to: Views.Auth
    forward "/shared", to: Views.SharedFiles
    forward "/", to: Views.Home

    def put_secret_key_base(conn, _opts) do
        put_in conn.secret_key_base, @secrets[:secret_key_base]
    end

end
