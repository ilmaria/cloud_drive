defmodule CloudDrive.TestData do
  use CloudDrive.Database
  use Amnesia
    
  Amnesia.transaction do
    ilmari = %User{username: "ilmari", password: "password"} |> User.write
    
    text_file = %File{
      name: "tiedosto",
      tags: ["testi"],
      mime_type: "text/plain",
      owner_id: ilmari.id,
      url: "shared/random/tiedosto",
      creation_time: DateTime.utc_now,
      modified_time: DateTime.utc_now
    } |> File.write
  end
  
end
