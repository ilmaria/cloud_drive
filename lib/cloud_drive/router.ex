defmodule CloudDrive.Router do
  alias CloudDrive.View, as: View
  use Plug.Router
  import CloudDrive.Database.FileUpload
  
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
    send_resp(conn, :ok, View.Index.render)
  end
  
  get "/new" do
    send_resp(conn, :ok, View.New.render)
  end
  
  post "/file-upload" do
    ok = save_to_database(conn)
    send_resp(conn, ok, View.New.render)
  end

  match _ do
    send_resp(conn, :not_found, "Not found")
  end
end
