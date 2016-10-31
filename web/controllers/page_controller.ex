defmodule CloudDrive.PageController do
  use CloudDrive.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
