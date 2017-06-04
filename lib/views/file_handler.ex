defmodule CloudDrive.Views.FileHandler do
  use Amnesia
  use CloudDrive.View
  use CloudDrive.Database
  require Logger

  get "/add" do
    template = render_template([])

    conn |> send_resp(:ok, template)
  end

  post "/upload" do
    files = conn.params["files"]
    user = conn |> get_session(:user)

    Enum.each files, fn file ->
      cloud_file = Amnesia.transaction do
        CloudFile.from(file, user) |> CloudFile.write_to_disk(file.path)
      end

      Logger.info """
      File upload
      User: #{user.email}
      File: #{cloud_file.name}
      Size: #{cloud_file.size |> Sizeable.filesize}\
      """
    end

    conn |> redirect(to: "/")
  end

  post "/remove" do
    file_ids = conn.params["fileIds"]

    Enum.map file_ids, fn file_id ->
      Amnesia.transaction do
        CloudFile.delete_from_disk(file_id)
      end

      Logger.info """
      File removed
      File id: #{file_id}\
      """
    end

    conn |> redirect(to: "/")
  end

  match _ do
    conn |> send_resp(:not_found, "Not found")
  end
end
