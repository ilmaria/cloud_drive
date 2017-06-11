defmodule CloudDrive.Views.Home do
    use Amnesia
    use CloudDrive.View
    use CloudDrive.Database
    alias CloudDrive.GoogleDrive
    require Logger

    get "/" do
        user = conn |> get_session(:user)
        credentials = conn |> get_session(:credentials)

        if user do
            conn = if !user.google_synced do
                GoogleDrive.sync_google_drive(user, credentials.token)

                synced_user = Amnesia.transaction do
                    User.write(%{user | google_synced: true})
                end

                conn |> put_session(:user, synced_user)
            else
                conn
            end

            files = Amnesia.transaction do
                CloudFile.match(owner_id: user.id) |> Amnesia.Selection.values()
            end

            tags = Amnesia.transaction do
                Enum.to_list(Tag.stream)
            end

            template = render_template(files: files, tags: tags, user: user)

            conn |> send_resp(:ok, template)
        else
            template = render_template(files: [])

            conn |> send_resp(:ok, template)
        end
    end

    def last_modified_time(file) do
        case file.modified_time |> Timex.format("{YYYY}-{0M}-{0D}") do
            {:ok, time} -> time
            {:error, reason} ->
                Logger.error inspect(reason, pretty: true)
                "-"
        end
    end

    def compact_size(nil), do: "-"
    def compact_size(file_size) do
        Sizeable.filesize(file_size, %{round: 1})
    end

    match _ do
        conn |> send_resp(:not_found, "Not found")
    end
end
