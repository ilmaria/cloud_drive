defmodule CloudDrive.View.Index do
  use Amnesia
  use CloudDrive.Template
  use CloudDrive.Database
  alias CloudDrive.Database, as: Db

  require Logger

  def render() do
    result = Amnesia.transaction do
      Db.File.where :owner_id == 0
    end
    Logger.debug result
    render_template([])
  end
end
