defmodule CloudDrive.View.Index do
  use Amnesia
  use CloudDrive.Template
  use CloudDrive.Database
  alias CloudDrive.Database

  require Logger

  def render(conn) do
    user = conn.assigns[:user]

    files = Database.where CloudFile,
      owner_id == user.id

    tags = Database.all(Tag)

    render_template(files: files, tags: tags)
  end
end
