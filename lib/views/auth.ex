defmodule CloudDrive.Views.Auth do
    use Amnesia
    use CloudDrive.View
    use CloudDrive.Database
    require Logger

    # Google will redirect to this route when user has logged in with a Google
    # account.
    get "/google/callback" do
        conn =
            case conn.assigns do
                %{ueberauth_auth: auth} ->
                    user = Amnesia.transaction do
                        [user] = User.match(email: auth.info.email)
                            |> Amnesia.Selection.values()

                        %{user |
                            refresh_token: auth.credentials.refresh_token,
                            access_token: auth.credentials.token
                        } |> User.write()
                    end

                    Logger.info "User: #{user.email} has logged in."

                    Logger.debug "--- auth ---"
                    Logger.debug inspect(auth, pretty: true)

                    conn
                        |> put_session(:user, user)
                _ ->
                    Logger.info "Login failed: " <> inspect(conn.assigns, pretty: true)
                    conn
            end

        conn |> redirect("/")
    end

    post "/logout" do
        conn
            |> configure_session(drop: true)
            |> redirect("/")
    end

    match _ do
        conn |> send_resp(:not_found, "Not found")
    end
end
