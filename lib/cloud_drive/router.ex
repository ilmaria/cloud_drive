defmodule CloudDrive.Router do
  import CloudDrive.Database.FileUpload
  use Plug.Router
  alias CloudDrive.View
  
  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :cloud_drive
  end

  plug Plug.Logger
  plug Plug.Static,
    at: "/static",
    from: "./web"
  plug CloudDrive.Authenticate
  plug Plug.Parsers,
    parsers: [:multipart],
    pass: ["*/*"]
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
    ok = save_to_database(conn)

    conn
    |> put_message(ok)
    |> redirect(to: "/")
  end

  match _ do
    send_resp(conn, :not_found, "Not found")
  end

  defp put_message(conn, message) do
    messages = conn.assigns[:messages]

    conn |> assign(:messages,
      case messages do
        nil -> [message]
        list -> [message | list]
      end)
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
