defmodule CloudDrive.Router do
  alias CloudDrive.View, as: View
  use Plug.Router

  plug Plug.Logger
  plug Plug.Static,
    at: "/static",
    from: "./web"
  
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, View.Index.render())
  end

  match _ do
    send_resp(conn, 404, "No")
  end
end
