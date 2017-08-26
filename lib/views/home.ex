defmodule CloudDrive.Views.Home do
    use Amnesia
    use CloudDrive.View
    use CloudDrive.Database
    alias CloudDrive.{GoogleDrive, Components}
    require Logger

    get "/" do
        user = conn |> get_session(:user)

        if user do
            user = if !user.google_synced do
                GoogleDrive.sync_google_drive(user, user.access_token)
            else
                user
            end

            files = Amnesia.transaction do
                CloudFile.match(owner_id: user.id) |> Amnesia.Selection.values()
            end

            tags = Amnesia.transaction do
                Enum.to_list(Tag.stream)
            end

            template =  Components.Index.render(user, files)

            conn
                |> put_session(:user, user)
                |> send_resp(:ok, template)
        else
            template = Components.Index.render(nil, [])

            conn |> send_resp(:ok, template)
        end
    end

    match _ do
        conn |> send_resp(:not_found, "Not found")
    end
end
