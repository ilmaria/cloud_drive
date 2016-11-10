defmodule CloudDrive.Database.FileUpload do
  use Amnesia
  use CloudDrive.Database
  alias CloudDrive.Database
  require Logger

  def save_to_database(conn) do
    files = conn.params["files"]
    user = conn.assigns[:user]

    Enum.each files, fn file ->
      cloud_file = Database.save(CloudFile, file, [user: user])

      Logger.info """
      File upload
      User: #{user.username}
      File: #{cloud_file.name}
      Size: #{cloud_file.size |> Sizeable.filesize}\
      """
    end

    :ok
  end
end
