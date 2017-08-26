defmodule CloudDrive.GoogleDrive do
    use Amnesia
    use CloudDrive.Database
    require Logger

    @api_endpoint "https://www.googleapis.com/drive/v3"

    # Get all files from Google Drive and sync their info to Cloud Drive
    # database.
    @spec sync_google_drive(User.t, String.t) :: none
    def sync_google_drive(user, token) do
        files = get_files(token)
        folders = get_folders(token)
        colors = tag_colors()
            |> Enum.shuffle()
            |> Stream.cycle()

        files_and_colors = Enum.zip(files, colors)

        Enum.each files_and_colors, fn {file, color} ->
            tags = create_tags(user, file, folders, color)

            Amnesia.transaction do
                CloudFile.from(file, user, tags) |> CloudFile.write()
            end
        end

        if files != [] do
            Amnesia.transaction do
                User.write(%{user | google_synced: true})
            end
        else
            user
        end
    end

    # Create tags for Google Drive files with parent folders as tag names.
    @spec create_tags(User.t, map, [map], String.t) :: [Tag.t]
    defp create_tags(user, file, folders, color) do
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
                        Tag.new(user, parent["name"], color) |> Tag.write()
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
                Logger.error "Token: #{token} #{inspect(error)}"
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
                Logger.error "Token: #{token} #{inspect(error)}"
                []
        end
    end


    # Use Google Drive `files.list` api to get a list of files or folders.
    @spec get_drive_file_list(String.t, keyword) :: {:ok, [map]}
        | {:error, HTTPoison.Error.t | Poison.ParseError.t}
    defp get_drive_file_list(token, params) do
        response = HTTPoison.get @api_endpoint <> "/files",
            [{"Accept", "application/json"},
            {"Authorization", "Bearer #{token}"}],
            params: params

        #TODO: check if response code is ok before doing anything
        with {:ok, %HTTPoison.Response{
                        status_code: status,
                        body: body
                    } } when 200 <= status and status <= 299 <- response,
             {:ok, body} <- Poison.decode(body)
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
            {:ok, %HTTPoison.Response{status_code: status}} ->
                reason = Plug.Conn.Status.reason_phrase(status)
                Logger.debug "err"
                {:error, "#{reason} - #{status}"}
            error -> error
        end
    end

    defp tag_colors() do
        [
			"#F0F8FF", "#FAEBD7", "#00FFFF", "#7FFFD4", "#F0FFFF", "#F5F5DC", "#FFE4C4", "#000000", "#FFEBCD", "#0000FF",
			"#8A2BE2", "#A52A2A", "#DEB887", "#5F9EA0", "#7FFF00", "#D2691E", "#FF7F50", "#6495ED", "#FFF8DC", "#DC143C",
			"#00FFFF", "#00008B", "#008B8B", "#B8860B", "#A9A9A9", "#A9A9A9", "#006400", "#BDB76B", "#8B008B", "#556B2F",
            "#FF8C00", "#9932CC", "#8B0000", "#E9967A", "#8FBC8F", "#483D8B", "#2F4F4F", "#2F4F4F", "#00CED1", "#9400D3",
			"#FF1493", "#00BFFF", "#696969", "#696969", "#1E90FF", "#B22222", "#FFFAF0", "#228B22", "#FF00FF", "#DCDCDC",
			"#F8F8FF", "#FFD700", "#DAA520", "#808080", "#808080", "#008000", "#ADFF2F", "#F0FFF0", "#FF69B4", "#CD5C5C",
			"#4B0082", "#FFFFF0", "#F0E68C", "#E6E6FA", "#FFF0F5", "#7CFC00", "#FFFACD", "#ADD8E6", "#F08080", "#E0FFFF",
			"#FAFAD2", "#D3D3D3", "#D3D3D3", "#90EE90", "#FFB6C1", "#FFA07A", "#20B2AA", "#87CEFA", "#778899", "#778899",
			"#B0C4DE", "#FFFFE0", "#00FF00", "#32CD32", "#FAF0E6", "#FF00FF", "#800000", "#66CDAA", "#0000CD", "#BA55D3",
			"#9370D8", "#3CB371", "#7B68EE", "#00FA9A", "#48D1CC", "#C71585", "#191970", "#F5FFFA", "#FFE4E1", "#FFE4B5",
			"#FFDEAD", "#000080", "#FDF5E6", "#808000", "#6B8E23", "#FFA500", "#FF4500", "#DA70D6", "#EEE8AA", "#98FB98",
			"#AFEEEE", "#D87093", "#FFEFD5", "#FFDAB9", "#CD853F", "#FFC0CB", "#DDA0DD", "#B0E0E6", "#800080", "#663399",
			"#FF0000", "#BC8F8F", "#4169E1", "#8B4513", "#FA8072", "#F4A460", "#2E8B57", "#FFF5EE", "#A0522D", "#C0C0C0",
			"#87CEEB", "#6A5ACD", "#708090", "#708090", "#FFFAFA", "#00FF7F", "#4682B4", "#D2B48C", "#008080", "#D8BFD8",
			"#FF6347", "#40E0D0", "#EE82EE", "#F5DEB3", "#FFFFFF", "#F5F5F5", "#FFFF00", "#9ACD32"
        ]
    end
end
