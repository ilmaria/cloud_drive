defmodule CloudDrive.Views.FileHandler do
  use CloudDrive.View
  use CloudDrive.Database
  alias CloudDrive.Database
  use Amnesia
  require Logger

  get "/add" do
    template = render_template([])

    conn |> send_resp(:ok, template)
  end

  post "/upload" do
    files = conn.params["files"]
    user = conn.assigns[:user]

    Enum.map files, fn file ->
      cloud_file = Database.save(CloudFile, file, [user: user])

      Logger.info """
      File upload
      User: #{user.username}
      File: #{cloud_file.name}
      Size: #{cloud_file.size |> Sizeable.filesize}\
      """
    end

    conn |> redirect(to: "/")
  end

  post "/remove" do
    fileIds = conn.params["fileIds"]

    Enum.map fileIds, fn fileId ->
      Database.remove(CloudFile, fileId)

      Logger.info """
      File removed
      File id: #{fileId}\
      """
    end

    conn |> redirect(to: "/")
  end

  match _ do
    conn |> send_resp(:not_found, "Not found")
  end
end
