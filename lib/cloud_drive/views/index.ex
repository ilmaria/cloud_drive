defmodule CloudDrive.View.Index do
  use Amnesia
  use CloudDrive.Template
  use Database

  require Logger

  def render() do
    result = Amnesia.transaction do
      User.first
    end
    IO.inspect result
    render_template([])
  end
end
