defmodule Database.FileUpload do
  use Amnesia
  use Database

  require Logger

  def put_to_database(files) do
    Enum.each files, fn file ->
      res = Amnesia.transaction do
        CloudFile.save(file)
      end
      IO.inspect res
    end
    
    :ok
  end
end
