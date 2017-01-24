defmodule CloudDrive.HomeController do
  use CloudDrive.Web, :controller

  def index(conn, _params) do
    user = conn |> get_session(:user)
    token = conn |> get_session(:google_token)

    files = if user do
      Storage.sync_with_google(user, token)
      user.files
    else
      []
    end

    render conn, "index.html", user: user, files: files
  end

end
