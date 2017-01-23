defmodule CloudDrive.HomeController do
  use CloudDrive.Web, :controller
  alias Storage.User
  alias Storage.Repo
  require Logger

  plug Ueberauth

  def index(conn, _params) do
    user = conn |> get_session(:user)

    render conn, "index.html", user: user
  end

  def auth_callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def auth_callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user = Repo.get_by!(User, email: auth.info.email)

    Logger.debug inspect(auth, pretty: true)

    conn
    |> put_session(:user, user)
    |> redirect(to: "/")
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

end
