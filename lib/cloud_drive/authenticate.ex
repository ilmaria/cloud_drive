defmodule CloudDrive.Authenticate do
  use Amnesia
  use CloudDrive.Database
  use Plug.Builder

  @secret Application.get_env(:cloud_drive, :secret)

  plug :put_secret_key_base
  plug Ueberauth

  def call(conn, _opts) do
    user = Amnesia.transaction do
      case User.first do
        nil -> %User{username: "ilmari", password: "ilmari"} |> User.write
        user -> user
      end
    end

    conn |> assign(:user, user)
  end

  def put_secret_key_base(conn, _) do
    put_in conn.secret_key_base, @secret[:secret_key_base]
  end
end
