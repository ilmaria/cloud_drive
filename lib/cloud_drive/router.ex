defmodule CloudDrive.Router do
  use Plug.Router
  use CloudDrive.Template

  plug Plug.Logger
  plug Plug.Static,
    at: "/static",
    from: {:cloud_drive, "/web/static"}
  
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, render("index.html"))
  end

  match _ do
    send_resp(conn, 404, "No")
  end
end
