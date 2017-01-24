defmodule CloudDrive.AuthController do
  use CloudDrive.Web, :controller
  alias Ueberauth.Strategy.Helpers
  require Logger

  plug Ueberauth

  def request(conn, _params) do
    redirect(conn, to: Ueberauth.Strategy.Helpers.request_url(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user = Storage.Repo.get_by!(Storage.User, email: auth.info.email)

    Logger.debug inspect(auth, pretty: true)

    conn
    |> put_session(:user, user)
    |> put_session(:google_token, auth.credentials.token)
    |> redirect(to: "/")
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

end
