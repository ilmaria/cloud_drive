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
      case User.first do
        nil -> %User{username: "ilmari", password: "ilmari"} |> User.write
        user -> user
      end
    end

    conn |> assign(:user, user)
  end
end
