defmodule CloudDrive.GoogleDrive do
    use Amnesia
    use CloudDrive.Database
    require Logger

    @token_endpoint "https://www.googleapis.com/oauth2/v4/token"
    @account_endpoint "https://accounts.google.com/o/oauth2/v2/auth"
    @api_endpoint "https://www.googleapis.com/drive/v3"
    @google_oauth Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)
    @client_id @google_oauth[:client_id]
    @client_secret @google_oauth[:client_secret]

    # Get all files from Google Drive and sync their info to Cloud Drive
    # database.
    @spec sync_google_drive(User.t, String.t) :: none
    def sync_google_drive(user, token) do
        files = get_files(token)
        folders = get_folders(token)

        Enum.each files, fn file ->
            tags = create_tags(user, file, folders)

            Amnesia.transaction do
                CloudFile.from(file, user, tags) |> CloudFile.write()
            end
        end
    end

    # Create tags for Google Drive files with parent folders as tag names.
    @spec create_tags(User.t, map, [map]) :: [Tag.t]
    defp create_tags(user, file, folders) do
        parents = file["parents"] || []

        Enum.map(parents, fn parent_id ->
            parent = Enum.find folders, fn folder ->
                folder["id"] == parent_id
            end

            if !parent do
                Logger.debug "Nil parent: #{inspect parents}"
                nil
            else
                Amnesia.transaction do
                    match = Tag.match(user_id: user.id, name: parent["name"])

                    if match do
                        Amnesia.Selection.values(match) |> hd()
                    else
                        Tag.new(user, parent["name"]) |> Tag.write()
                    end
                end
            end
        end) |> Enum.reject(&is_nil/1)
    end

    # Get a list of all Google Drive files.
    @spec get_files(String.t) :: [map]
    def get_files(token) do
        params = [
            q: "mimeType != 'application/vnd.google-apps.folder' and trashed = false",
            fields: "files(id,createdTime,mimeType,modifiedTime,name,parents,size,webViewLink),nextPageToken",
            spaces: "drive",
            pageSize: 1000
        ]

        case get_drive_file_list(token, params) do
            {:ok, file_list} -> file_list
            error ->
                Logger.error inspect(error)
                []
        end
    end

    # Get a list of all Google Drive folders.
    @spec get_folders(String.t) :: [map]
    def get_folders(token) do
        params = [
            q: "mimeType = 'application/vnd.google-apps.folder' and trashed = false",
            fields: "files(id,name),nextPageToken",
            spaces: "drive",
            pageSize: 1000
        ]

        case get_drive_file_list(token, params) do
            {:ok, folder_list} -> folder_list
            error ->
                Logger.error inspect(error)
                []
        end
    end


    # Use Google Drive `files.list` api to get a list of files or folders.
    @spec get_drive_file_list(String.t, keyword) :: {:ok, [map]}
        | {:error, HTTPoison.Error.t | Poison.ParseError.t}
    defp get_drive_file_list(token, params) do
        response = HTTPoison.get @api_endpoint <> "/files",
            [{"Content-Type", "application/json"},
            {"Authorization", "Bearer #{token}"}],
            params: params

        #TODO: check if response code is ok before doing anything
        with {:ok, resp} <- response,
             {:ok, body} <- Poison.decode(resp.body)
        do
            page_token = body["nextPageToken"]

            if page_token do
                updated_params = Keyword.put(params, :pageToken, page_token)
                next_page = get_drive_file_list(token, updated_params)

                case next_page do
                    {:ok, additional_files} -> {:ok, additional_files ++ body["files"]}
                    _ -> {:ok, []}
                end
            else
                {:ok, body["files"]}
            end
        else
            error -> error
        end
    end
end
