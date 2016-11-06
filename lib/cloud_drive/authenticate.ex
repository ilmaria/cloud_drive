defmodule CloudDrive.Authenticate do
  use Amnesia
  use CloudDrive.Database
  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    user = Amnesia.transaction do
      User.first
    end
    
    conn |> assign(:user, user)
  end
end
