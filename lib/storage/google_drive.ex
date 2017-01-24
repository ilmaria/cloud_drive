defmodule Storage.GoogleDrive do
  require Logger

  @token_endpoint "https://www.googleapis.com/oauth2/v4/token"
  @account_endpoint "https://accounts.google.com/o/oauth2/v2/auth"
  @api_endpoint "https://www.googleapis.com/drive/v3"
  @google_oauth Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)
  @client_id @google_oauth[:client_id]
  @client_secret @google_oauth[:client_secret]

  #Get all files from Google Drive and sync their info to Cloud Drive database.
  def sync(user, token) do
    files = get_files(token)
    folders = get_folders(token)

    Enum.each files, fn google_file ->
      parents = google_file["parents"] || []

      file = google_file
      |> to_storage_file(user)
      |> add_tags(folders, parents)

      case Storage.Repo.get_by(Storage.File, Map.to_list(file.data)) do
        nil -> file
        existing_file -> existing_file
      end
      |> Storage.Repo.insert_or_update
    end
  end

  # Add tags to file by using Google Drive parent folders as tag names.
  defp add_tags(file, folders, parents \\ []) do
    tags =
      Enum.map(parents, fn parent_id ->
        parent = Enum.find folders, fn folder ->
          folder.id == parent_id
        end

        if !parent do
          Logger.debug "Nil parent: #{inspect(parents)}"
          nil
        else
          name = parent["name"]
          case Storage.Repo.get_by(Tag, name: name) do
            nil -> Storage.Repo.insert!(%Storage.Tag{name: name})
            tag -> tag
          end
        end
      end) |> Enum.reject(&is_nil/1)

    Storage.File.changeset(file, tags: tags)
  end

  #Get a list of all Google Drive files.
  defp get_files(token) do
    params = [
      q: "mimeType != 'application/vnd.google-apps.folder' and trashed = false",
      fields: "files(createdTime,mimeType,modifiedTime,name," <>
        "parents,size,webViewLink),nextPageToken",
      spaces: "drive",
      pageSize: 1000
    ]

    case get_file_list(token, params) do
      {:ok, file_list} -> file_list
      error -> []
    end
  end

  #Get a list of all Google Drive folders.
  defp get_folders(token) do
    params = [
      q: "mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      fields: "files(id,name),nextPageToken",
      spaces: "drive",
      pageSize: 1000
    ]

    case get_file_list(token, params) do
      {:ok, folder_list} -> folder_list
      error -> []
    end
  end


  # Use Google Drive `files.list` api to get a list of files or folders.
  defp get_file_list(token, params) do
    url = @api_endpoint <> "/files"
    headers = [{"Content-Type", "application/json"},
               {"Authorization", "Bearer #{token}"}]

    with {:ok, resp} <- HTTPoison.get(url, headers, params: params),
         {:ok, files, next_token} <- parse_files(resp.body) do

      if next_token do
        updated_params = Keyword.put(params, :pageToken, next_token)
        next_page = get_file_list(token, updated_params)

        additional_files = case next_page do
          {:ok, list} -> list
          _ -> []
        end

        {:ok, additional_files ++ files}
      else
        {:ok, files}
      end

    else
      error ->
        Logger.error inspect(error, pretty: true)
        error
    end
  end

  defp parse_files(json_body) do
    data = Poison.decode! json_body

    {:ok, data["files"], Map.get(data, "nextPageToken")}
  end

  # Transform Google Drive file into Storage.File.
  defp to_storage_file(google_file, user) do
    file_params = %{
      owner: user,
      name: google_file["name"],
      mime_type: google_file["mimeType"],
      edit_url: google_file["webViewLink"],
      #TODO: fix download url
      download_url: "",
      size: google_file["size"],
      google_file?: true
    }
    Storage.File.changeset(%Storage.File{}, file_params)
  end
end
