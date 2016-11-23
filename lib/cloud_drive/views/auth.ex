defmodule CloudDrive.Views.Auth do
  use CloudDrive.View

  # Google will redirect to this route when user has logged in with a Google
  # account.
  get "/google/callback" do
    conn =
      case conn.assigns do
        %{ueberauth_auth: auth} ->
          user = auth
          IO.inspect user
          conn |> put_session(:user, user)
        _ ->
          IO.inspect conn.assigns
          conn
      end

    conn |> redirect(to: "/")
  end

  match _ do
    conn |> send_resp(:not_found, "Not found")
  end
end
