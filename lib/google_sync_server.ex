defmodule CloudDrive.GoogleSyncServer do
    use Amnesia
    use GenServer
    use CloudDrive.Database
    require Logger

    @token_endpoint "https://www.googleapis.com/oauth2/v4/token"
    @account_endpoint "https://accounts.google.com/o/oauth2/v2/auth"
    @api_endpoint "https://www.googleapis.com/drive/v3"
    @google_oauth Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)
    @client_id @google_oauth[:client_id]
    @client_secret @google_oauth[:client_secret]


    # Client

    def start_link(name \\ __MODULE__) do
        GenServer.start_link(__MODULE__, [name: name])
    end


    # Server (callbacks)

    defmodule Token do
        @type t :: %__MODULE__{
            user: User.t,
            access_token: String.t,
            expires_in: non_neg_integer,
        }

        defstruct [:user, :access_token, :expires_in]
    end

    def init(_args) do
        users = Amnesia.transaction do
            User.stream()
        end

        state = Enum.filter(users, fn user -> user.google_synced end)
            |> Enum.map(fn user ->
                {access_token, expires_in} =
                    case new_access_token(user.refresh_token) do
                        %{"access_token": access_token, "expires_in": expires_in} ->
                            {access_token, expires_in}
                        error ->
                            Logger.debug inspect error
                            {"", 0}
                    end

                %Token{
                    user: user,
                    access_token: access_token,
                    expires_in: expires_in,
                }
            end)

        {:ok, state}
    end

    # Refresh Google Drive token.
    @spec new_access_token(String.t) :: {:ok, String.t}
        | {:error, HTTPoison.Error.t | Poison.ParseError.t}
    defp new_access_token(refresh_token) do
        response = HTTPoison.post @token_endpoint,
            [{"Content-Type", "application/x-www-form-urlencoded"}],
            params: [
                client_id: @client_id,
                client_secret: @client_secret,
                refresh_token: refresh_token,
                grant_type: "refresh_token"
            ]

        with {:ok, resp} <- response,
             {:ok, body} <- Poison.decode(resp.body)
        do
            {:ok, Map.take(body, ["access_token", "expires_in"])}
        else
            error -> error
        end
    end
end
