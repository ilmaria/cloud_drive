defmodule CloudDrive.GoogleDrive do
  use CloudDrive.Database, as: Database
  require Logger

  @token_endpoint "https://www.googleapis.com/oauth2/v4/token"
  @account_endpoint "https://accounts.google.com/o/oauth2/v2/auth"
  @api_endpoint "https://www.googleapis.com/drive/v3"
  @google_oauth Application.get_env(
    :ueberauth, Ueberauth.Strategy.Google.OAuth)
  @client_id @google_oauth[:client_id]
  @client_secret @google_oauth[:client_secret]

  def sync() do
    file_list = files(
      orderBy: "name",
      q: "mimeType != 'application/vnd.google-apps.folder' and trashed = false",
      spaces: "drive")

    Enum.each file_list, fn file ->
      Database.save(CloudFile, file)
    end
  end

  def refresh_token!(token) do
    case refresh_token do
      {:ok, resp} -> resp
      {:error, reason} -> throw reason
    end
  end

  def refresh_token(token) do
    response = HTTPoison.post @token_endpoint,
      [{"Content-Type", "application/x-www-form-urlencoded"}],
      params: [
        client_id: @client_id,
        client_secret: @client_secret,
        refresh_token: token,
        grant_type: "refresh_token"
      ]

    case response do
      {:ok, resp} ->
        new_token = resp.body
        |> Poison.decode!
        |> Map.take ["access_token", "expires_in"]

        {:ok, new_token}
      _ ->
        response
    end
  end

  def files!(params \\ []) do
    case files do
      {:ok, resp} -> resp
      {:error, reason} -> throw reason
    end
  end

  def files(params \\ []) do
    response = HTTPoison.get @api_endpoint <> "/files",
      [{"Content-Type", "application/json"}],
      params: params

    case response do
      {:ok, resp} -> {:ok, Poison.decode! resp.body}
      _ -> response
    end
  end
end
