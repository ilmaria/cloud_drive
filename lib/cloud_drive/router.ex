defmodule CloudDrive.Router do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello my world2")
  end

  match _ do
    send_resp(conn, 404, "No")
  end
end
