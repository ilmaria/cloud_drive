defmodule CloudDrive.View.Index do
  use Amnesia
  use Timex
  use CloudDrive.Database
  use CloudDrive.Template
  alias CloudDrive.Database

  require Logger

  def render(conn) do
    user = conn.assigns[:user]

    files = Database.where CloudFile,
      owner_id == user.id

    tags = Database.all(Tag)

    render_template(files: files, tags: tags)
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
end
