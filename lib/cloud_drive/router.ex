defmodule CloudDrive.Router do
  use Plug.Router
  use Amnesia
  use CloudDrive.Database
  alias CloudDrive.{Database, View}
  require Logger

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :cloud_drive
  end

  plug Plug.Logger
  plug Plug.Static,
    at: "/static",
    from: "./web"
  plug CloudDrive.Authenticate
  plug Plug.Parsers,
    parsers: [:multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
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
