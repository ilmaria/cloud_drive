defmodule CloudDrive.Router do
  use Plug.Router
  use CloudDrive.Database
  use Amnesia
  alias CloudDrive.Views
  require Logger

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :cloud_drive
  end

  ## Plugs ##
  plug Plug.Logger

  plug Plug.Static,
    at: "/static",
    from: "./web"

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
  plug :assign_user
  plug :match
  plug :dispatch

  ## Routes ##
  forward "/file", to: Views.FileHandler

  forward "/auth", to: Views.Auth

  forward "/", to: Views.Home

  @secret Application.get_env(:cloud_drive, :secret)

  def put_secret_key_base(conn, _opts) do
    put_in conn.secret_key_base, @secret[:secret_key_base]
  end

  def assign_user(conn, _opts) do
    user = Amnesia.transaction do
      case User.first do
        nil -> %User{username: "ilmari", password: "ilmari"} |> User.write
        user -> user
      end
    end

    conn |> assign(:user, user)
  end

end
