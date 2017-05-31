defmodule CloudDrive.Views.Auth do
  use CloudDrive.View
  alias CloudDrive.Storage
  require Logger

  # Google will redirect to this route when user has logged in with a Google
  # account.
  get "/google/callback" do
    conn =
      case conn.assigns do
        %{ueberauth_auth: auth} ->
          user = Storage.get(:users, auth.info.email)

          Logger.info "User: #{user.email} has logged in."

          Logger.debug "Assign token to session"
          Logger.debug auth.credentials.token
          Logger.debug "--- auth ---"
          Logger.debug inspect(auth, pretty: true)
          conn
          |> put_session(:user, user)
          |> put_session(:google_api_token, auth.credentials.token)
        _ ->
          Logger.info "Login failed:"
          Logger.info inspect(conn.assigns, pretty: true)
          conn
      end

    conn |> redirect(to: "/")
  end

  post "/logout" do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  match _ do
    conn |> send_resp(:not_found, "Not found")
  end
end
