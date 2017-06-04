defmodule CloudDrive.Views.SharedFiles do
    use CloudDrive.View
    use Amnesia
    use CloudDrive.Database

    require Logger

    @app_settings Application.get_env(:cloud_drive, :settings)
    @shared_folder @app_settings[:shared_files_folder]

    get "/:file_id/:file_name" do
        file = Amnesia.transaction do
            CloudFile.read(file_id)
        end

        Logger.debug "file_id: #{file_id}"
        Logger.debug "file: #{inspect file}"

        if file do
            conn |> send_file(200, @shared_folder <> file_id)
        else
            conn |> send_resp(:not_found, "Not found")
        end
    end

    match _ do
        conn |> send_resp(:not_found, "Not found")
    end
end
