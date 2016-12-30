defmodule CloudDrive.Views.Auth do
  use CloudDrive.View
  use CloudDrive.Database, as: Database
  require Logger

  # Google will redirect to this route when user has logged in with a Google
  # account.
  get "/google/callback" do
    conn =
      case conn.assigns do
        %{ueberauth_auth: auth} ->
          Logger.info(inspect auth.credentials, pretty: true)
          user = Database.get(User, email: auth.info.email)

          Logger.info "User: #{user} has logged in."

          IO.puts "Assign token to session"
          IO.puts auth.credentials.token
          conn
          |> put_session(:user, user)
          |> put_session(:google_api_token, auth.credentials.token)
        _ ->
          Logger.info "Login failed: #{inspect conn.assigns, pretty: true}"

          conn
      end

    _ = """
    %User{email: "ilmari.autio@gmail.com", name: "Ilmari"} |> User.write
    a = %Ueberauth.Auth{
      credentials: %Ueberauth.Auth.Credentials{
        expires: true, expires_at: 1479990770,
        other: %{}, refresh_token: nil, scopes: [""],
        secret: nil,
        token: "ya29.Ci-gA4j4bSOA2Uis7NuEmpaARJDGOwlA3YXI18XHIFc-TDp02-twqST5SaumF4cPPg",
        token_type: nil
      },
      extra: %Ueberauth.Auth.Extra{
        raw_info: %{
          token: %OAuth2.AccessToken{
            access_token: "ya29.Ci-gA4j4bSOA2Uis7NuEmpaARJDGOwlA3YXI18XHIFc-TDp02-twqST5SaumF4cPPg",
            client: %OAuth2.Client{
              authorize_url: "/o/oauth2/v2/auth",
              client_id: "449277186504-hpsge8dcqskei7bq4r2r43if40j81t2e.apps.googleusercontent.com",
              client_secret: "P7rCWL2ap2ogX5DiG9iFvsqs",
              headers: [],
              params: %{
                "client_id" => "449277186504-hpsge8dcqskei7bq4r2r43if40j81t2e.apps.googleusercontent.com",
                "client_secret" => "P7rCWL2ap2ogX5DiG9iFvsqs",
                "code" => "4/LWc1KpPdhVaAbbZim6-A3uwudTTRHQniab-vPQxPORk",
                "grant_type" => "authorization_code",
                "redirect_uri" => "http://localhost:8000/auth/google/callback"
              },
              redirect_uri: "http://localhost:8000/auth/google/callback",
              site: "https://accounts.google.com",
              strategy: Ueberauth.Strategy.Google.OAuth,
              token_method: :post,
              token_url: "https://www.googleapis.com/oauth2/v4/token"
            },
            expires_at: 1479990770,
            other_params: %{
              "id_token" => "eyJhbGciOiJSUzI1NiIsImtpZCI6ImY2YTMzZmZiMjU1MDkxZWRiNTJiYzQ5MzY0MDc2YjNhMzQ4NzQ1YjEifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJpYXQiOjE0Nzk5ODcxNzIsImV4cCI6MTQ3OTk5MDc3MiwiYXRfaGFzaCI6IjdwTmM0THp1WjFCM0Rya0ZSRVVZWEEiLCJhdWQiOiI0NDkyNzcxODY1MDQtaHBzZ2U4ZGNxc2tlaTdicTRyMnI0M2lmNDBqODF0MmUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTY3MzUxMjcwNzUwNjQ5MTUwMTYiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiNDQ5Mjc3MTg2NTA0LWhwc2dlOGRjcXNrZWk3YnE0cjJyNDNpZjQwajgxdDJlLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiZW1haWwiOiJpbG1hcmkuYXV0aW9AZ21haWwuY29tIn0.yKb_gNWh---PlsPc7PPwUonXYPmYvTQdgBRfMKJHzo7L7Rllx1dNyqwHYE6LfhAMZv-vgfKQJbjGrsdW11Qoqz6ECoSIAsHRiu8r_HXP1nUvz3bc9p-B0DDf4NBjFGlPTjP6Sqjgw3ErBsRmgpVlIJTlAfX9SAhaMvfyHG6y9A27oKj8raQFRk9Sru9H2MaYYRVqbcz0lChBUY7adXV6kG2UAcFjBlmiGGELd9P3iQkv4l28wVqGOUk0nHNz_1GU2ibdAbkUBr6K1_DO3EbnIY7xKNDZzOUEGObrNhNT3WwS2cR8PRyBXS0X-R_A6Ixxh_p_1poitM2Vo2dzAncMag"
            },
            refresh_token: nil,
            token_type: "Bearer"
          },
          user: %{
            "email" => "ilmari.autio@gmail.com",
            "email_verified" => true,
            "family_name" => "Autio",
            "gender" => "male",
            "given_name" => "Ilmari",
            "name" => "Ilmari Autio",
            "picture" => "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg",
            "profile" => "https://plus.google.com/116735127075064915016",
            "sub" => "116735127075064915016"
          }
        }
      },
      info: %Ueberauth.Auth.Info{
        description: nil,
        email: "ilmari.autio@gmail.com",
        first_name: "Ilmari",
        image: "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg",
        last_name: "Autio",
        location: nil,
        name: "Ilmari Autio",
        nickname: nil,
        phone: nil,
        urls: %{profile: "https://plus.google.com/116735127075064915016", website: nil}
      },
      provider: :google,
      strategy: Ueberauth.Strategy.Google,
      uid: "116735127075064915016"
    }
    """

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
