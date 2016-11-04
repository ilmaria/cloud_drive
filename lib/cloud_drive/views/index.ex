defmodule CloudDrive.View.Index do
  use Amnesia
  use CloudDrive.Template
  use CloudDrive.Database

  require Logger

  def render() do
    result = Amnesia.transaction do
      CloudFile.first
    end
    Logger.debug result
    render_template([])
  end
end
