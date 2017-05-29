defmodule CloudDrive.Views.SharedFiles do
  use CloudDrive.View
  use CloudDrive.Database, as: Database
  alias CloudDrive.Hashids, as: H

  require Logger

  @app_settings Application.get_env(:cloud_drive, :settings)
  @shared_folder @app_settings[:shared_files_folder]

  get "/:hash/:file_name" do
    {:ok, [file_id]} = H.decode(hash)

    file = Database.get CloudFile,
      id: file_id,
      name: file_name

    Logger.info "file_id: #{file_id}"
    Logger.info "file: #{inspect file}"

    if file do
      Logger.info "yes"
      conn |> send_file(200, @shared_folder <> hash)
    else
      Logger.info "no"
      conn |> send_resp(:not_found, "Not found")
    end
  end

  match _ do
    conn |> send_resp(:not_found, "Not found")
  end
end
