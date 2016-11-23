defmodule CloudDrive.Router do
  use Plug.Router
  use Amnesia
  use CloudDrive.Database
  alias CloudDrive.{Database, View}
  require Logger

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :cloud_drive
  end

  @secret Application.get_env(:cloud_drive, :secret)

  plug Plug.Logger
  plug Plug.Static,
    at: "/static",
    from: "./web"

  plug :put_secret_key_base

  plug Plug.Parsers,
    parsers: [:multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.Session,
    store: :cookie,
    key: "_cloud_drive_session",
    encryption_salt: "cookie store encryption salt",
    signing_salt: "cookie store signing salt",
    key_length: 64,
    log: :debug

  plug Ueberauth #plug CloudDrive.Authenticate
  plug :fetch_session

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> send_resp(:ok, View.Index.render(conn))
  end

  get "/new" do
    conn
    |> send_resp(:ok, View.New.render(conn))
  end

  # Route to authenticate with Google. We don't do anything here because
  # CloudDrive.Authenticate will intercept this route and redirect it to
  # Google.
  #get "/auth/google" do
    #conn |> send_resp(:ok, "hello")
  #end

  # Google will redirect to this route when user has logged in with a Google
  # account.
  get "/auth/google/callback" do
    conn =
      case conn.assigns do
        %{ueberauth_auth: auth} ->
          user = auth.info
          IO.inspect user
          conn |> put_session(:user, user)
        _ ->
          IO.inspect conn.assigns
          conn
      end

    conn |> redirect(to: "/")
  end

  post "/file-upload" do
    files = conn.params["files"]
    user = conn.assigns[:user]

    Enum.map files, fn file ->
      cloud_file = Database.save(CloudFile, file, [user: user])

      Logger.info """
      File upload
      User: #{user.username}
      File: #{cloud_file.name}
      Size: #{cloud_file.size |> Sizeable.filesize}\
      """
    end

    conn
    |> redirect(to: "/")
  end

  post "/file-remove" do
    fileIds = conn.params["fileIds"]

    Enum.map fileIds, fn fileId ->
      Database.remove(CloudFile, fileId)

      Logger.info """
      File removed
      File id: #{fileId}\
      """
    end

    conn
    |> redirect(to: "/")
  end

  match _ do
    send_resp(conn, :not_found, "Not found")
  end

  #defp put_message(conn, message) do
  #  messages = conn.assigns[:messages]
  #
  #  conn |> assign(:messages,
  #    case messages do
  #      nil -> [message]
  #      list -> [message | list]
  #    end)
  #end

  def put_secret_key_base(conn, _) do
    put_in conn.secret_key_base, @secret[:secret_key_base]
  end

  defp redirect(conn, opts) do
    url = opts[:to]
    body = """
    <!DOCTYPE html>
    You are being <a href="#{url}>redirected</a>.
    """

    conn
    |> put_resp_header("location", url)
    |> send_resp(conn.status || :found, body)
  end
end
