defmodule CloudDrive.Views.Home do
  use CloudDrive.View
  use CloudDrive.Database, as: Database
  use Timex
  require Logger

  get "/" do
    user = conn |> get_session(:user)

    files =
      if user do
        Database.where CloudFile,
          owner_id == user.id
      else
        []
      end

    tags = Database.all(Tag)

    template = render_template(files: files, tags: tags, user: user)

    conn |> send_resp(:ok, template)
  end

  def last_modified_time(file) do
    case file.modified_time
    |> Timex.format("{relative}", :relative) do
      {:ok, time} -> time
      {:error, reason} ->
        Logger.error reason
        "-"
    end
  end

  match _ do
    conn |> send_resp(:not_found, "Not found")
  end
end
