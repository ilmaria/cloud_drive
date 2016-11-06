defmodule CloudDrive.View.Index do
  use Amnesia
  use CloudDrive.Template
  use CloudDrive.Database
  alias Amnesia.Selection

  require Logger

  def render(conn) do
    user = conn.assigns[:user]

    files = Amnesia.transaction do
      CloudFile.match(
        owner_id: user.id
      ) |> Selection.values
    end

    tags = Amnesia.transaction do
      Tag.where(true) |> Selection.values
    end

    render_template(files: files, tags: tags)
  end
end
