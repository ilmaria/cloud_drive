defmodule CloudDrive.HomeController do
  use CloudDrive.Web, :controller

  def index(conn, _params) do
    user = conn |> get_session(:user)

    render conn, "index.html", user: user
  end

end
