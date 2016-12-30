defmodule CloudDrive.GoogleDrive do
  use CloudDrive.Database, as: Database
  alias CloudDrive.GoogleDrive
  require Logger

  @token_endpoint "https://www.googleapis.com/oauth2/v4/token"
  @account_endpoint "https://accounts.google.com/o/oauth2/v2/auth"
  @api_endpoint "https://www.googleapis.com/drive/v3"
  @google_oauth Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)
  @client_id @google_oauth[:client_id]
  @client_secret @google_oauth[:client_secret]

  @doc"""
  Get all files from Google Drive and sync their info to Cloud Drive
  database.
  """
  def import_google_drive(user, token) do
    files = get_files(token)
    folders = get_folders(token)

    Enum.each files, fn file ->
      tags = create_tags(file, folders)

      Database.save(CloudFile, file, user: user, tags: tags)
    end
  end

  # Create tags for Google Drive files by using parent folders as tag names.
  defp create_tags(file, folders) do
    parents = if file.parents, do: file.parents, else: []

    Enum.map parents, fn parent_id ->
      parent = Enum.find folders, fn folder ->
        folder.id == parent_id
      end

      if is_nil parent do
        Logger.info "Nil parent: #{inspect(parents)}"
        #Logger.info inspect(folders)
      else
        Database.get_or_create_tag(parent.name)
      end
    end
  end

  @doc"""
  Get a list of all Google Drive files.
  """
  def get_files(token) do
    params = [
      q: "mimeType != 'application/vnd.google-apps.folder' and trashed = false",
      fields: "files(createdTime,mimeType,modifiedTime,name," <>
        "parents,size,webViewLink),nextPageToken",
      spaces: "drive",
      pageSize: 1000
    ]

    case get_drive_file_list(token, params, GoogleDrive.File) do
      {:ok, file_list} -> file_list
      error ->
        Logger.error inspect(error)
        []
    end
  end

  @doc"""
  Get a list of all Google Drive folders.
  """
  def get_folders(token) do
    params = [
      q: "mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      fields: "files(id,name),nextPageToken",
      spaces: "drive",
      pageSize: 1000
    ]

    case get_drive_file_list(token, params, GoogleDrive.Folder) do
      {:ok, folder_list} -> folder_list
      error ->
        Logger.error inspect(error)
        []
    end
  end


  # Use Google Drive `files.list` api to get a list of files or folders.
  defp get_drive_file_list(token, params, struct_module) do
    response = HTTPoison.get @api_endpoint <> "/files",
      [{"Content-Type", "application/json"},
       {"Authorization", "Bearer #{token}"}],
      params: params

    case response do
      {:ok, resp} ->
        resp_body = Poison.decode! resp.body
        next_token = Map.get(resp_body, "nextPageToken")
        files = Enum.map resp_body["files"], fn file_map ->
          Poison.Decode.decode file_map, as: struct!(struct_module)
        end

        if !next_token do
          {:ok, files}
        else
          updated_params = Keyword.put(params, :pageToken, next_token)
          next_page = get_drive_file_list(token, updated_params, struct_module)
          additional_files = case next_page do
            {:ok, list} -> list
            _ -> []
          end
          {:ok, additional_files ++ files}
        end

      error ->
        error
    end
  end

  @doc"""
  Refresh Google Drive token. Throw on error.
  """
  def new_access_token!(refresh_token) do
    case new_access_token(refresh_token) do
      {:ok, resp} -> resp
      {:error, reason} -> throw reason
    end
  end

  @doc"""
  Refresh Google Drive token.
  """
  def new_access_token(refresh_token) do
    response = HTTPoison.post @token_endpoint,
      [{"Content-Type", "application/x-www-form-urlencoded"}],
      params: [
        client_id: @client_id,
        client_secret: @client_secret,
        refresh_token: refresh_token,
        grant_type: "refresh_token"
      ]

    case response do
      {:ok, resp} ->
        new_token = resp.body
        |> Poison.decode!
        |> Map.take(["access_token", "expires_at"])

        {:ok, new_token}
      _ ->
        response
    end
  end
end
