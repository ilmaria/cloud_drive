defmodule CloudDrive.Views.Home do
  use CloudDrive.View
  alias CloudDrive.Storage
  import CloudDrive.GoogleDrive
  require Logger

  get "/" do
    user = conn |> get_session(:user)
    token = conn |> get_session(:google_api_token)

    if user do
      if !user.gdrive_synced do
        sync_google_drive(user, token)
        Storage.insert(:users, %{user | gdrive_synced: true}, [id: user.email])
      end

      # Match user's email to file owner
      files = Storage.select(:files,
        {:'_', %Storage.File{owner_email: ^user.email}})

      tags = Storage.all(:tags)
      template = render_template(files: files, tags: tags, user: user)

      conn |> send_resp(:ok, template)
    else
      template = render_template(files: [])

      conn |> send_resp(:ok, template)
    end
  end

  def last_modified_time(file) do
    case file.modified_time
    |> Timex.format("{YYYY}-{0M}-{0D}") do
      {:ok, time} -> time
      {:error, reason} ->
        Logger.error inspect(reason, pretty: true)
        "-"
    end
  end

  def compact_size(nil), do: "-"
  def compact_size(file_size) do
    Sizeable.filesize(file_size, %{round: 1})
  end

  match _ do
    conn |> send_resp(:not_found, "Not found")
  end
end
