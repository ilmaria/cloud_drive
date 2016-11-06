defmodule CloudDrive.Database.FileUpload do
  use Amnesia
  use CloudDrive.Database
  require Logger

  def save_to_database(conn) do
    files = conn.params["files"]
    user = conn.assigns[:user]

    Enum.each files, fn file ->
      Amnesia.transaction do
        CloudFile.save(file, [user: user])
      end

      file_size = File.stat!(file.path).size
        |> Sizeable.filesize

      Logger.info """
      File upload
      User: #{user.username}
      File: #{file.filename}
      Size: #{file_size}\
      """
    end
    
    :ok
  end
end
