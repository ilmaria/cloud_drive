defmodule CloudDrive.View.New do
  use Amnesia
  use CloudDrive.Template
  use CloudDrive.Database

  require Logger

  def render(_conn) do
    render_template([])
  end
end
