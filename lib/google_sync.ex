defmodule CloudDrive.GoogleSync do
    use Amnesia
    use Task, restart: :permanent # Restart task always when it stops
    use CloudDrive.Database
    require Logger

    @token_endpoint "https://www.googleapis.com/oauth2/v4/token"
    @google_oauth Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)
    @client_id @google_oauth[:client_id]
    @client_secret @google_oauth[:client_secret]

    def start_link(_args) do
        Task.start_link(__MODULE__, :loop, [])
    end

    # Check users' token expiration and get a new access_token if it's
    # is about to expire
    def loop() do
        users = Amnesia.transaction do
            User.stream
                |> Enum.to_list()
                |> Enum.filter(fn user -> user.refresh_token end)
        end

        Enum.each(users, fn user ->
            if !user.token_expiration || user.token_expiration < 10 do
                {access_token, expires_in} =
                    case new_access_token(user.refresh_token) do
                        {:ok, %{"access_token" => access_token,
                                "expires_in" => expires_in}} ->
                            {access_token, expires_in}
                        error ->
                            Logger.error inspect error
                            {"", 0}
                    end
                Amnesia.transaction do
                   %{user |
                        access_token: access_token,
                        token_expiration: expires_in
                    } |> User.write()
                end
            else
                Amnesia.transaction do
                    %{user |
                        token_expiration: user.token_expiration - 5
                    } |> User.write()
                end
            end
        end)

        Process.sleep(5000)

        loop()
    end

    # Refresh Google Drive token.
    @spec new_access_token(String.t) :: {:ok, Map.t}
        | {:error, HTTPoison.Error.t | Poison.ParseError.t}
    defp new_access_token(refresh_token) do
        response = HTTPoison.post @token_endpoint,
            URI.encode_query([
                client_id: @client_id,
                client_secret: @client_secret,
                refresh_token: refresh_token,
                grant_type: "refresh_token"
            ]),
            [{"Content-Type", "application/x-www-form-urlencoded"}]

        with {:ok, resp} <- response,
             {:ok, body} <- Poison.decode(resp.body)
        do
            Logger.debug inspect body
            {:ok, Map.take(body, ["access_token", "expires_in"])}
        else
            error -> error
        end
    end
end
