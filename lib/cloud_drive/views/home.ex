defmodule CloudDrive.Views.Home do
  use CloudDrive.View
  use CloudDrive.Database
  alias CloudDrive.Database
  use Amnesia
  use Timex
  require Logger

  get "/" do
    user = Amnesia.transaction do
      case User.first do
        nil -> %User{username: "ilmari", password: "ilmari"} |> User.write
        user -> user
      end
    end

    auth_user = conn |> get_session(:user)

    files = Database.where CloudFile,
      owner_id == user.id
    tags = Database.all(Tag)
    template = render_template(files: files, tags: tags, user: auth_user)

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
