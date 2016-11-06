defmodule CloudDrive.View.New do
  use Amnesia
  use CloudDrive.Template
  use CloudDrive.Database

  require Logger

  def render() do
    render_template([])
  end
end
