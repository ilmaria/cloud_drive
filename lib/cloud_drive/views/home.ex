defmodule CloudDrive.Views.Home do
  use CloudDrive.View
  use CloudDrive.Database, as: Database
  import CloudDrive.GoogleDrive
  require Logger

  get "/" do
    user = conn |> get_session(:user)
    token = conn |> get_session(:google_api_token)

    if user do
      #import_google_drive(user, token)
    end

    files =
      if user do
        Database.where CloudFile,
          owner_id == user.id
      else
        []
      end

    _ = """
    HTTPoison.get("https://www.googleapis.com/drive/v3/files",
      [{"Authorization", "Bearer #{token}"}],
      params: [pageSize: 100, q: "'root' in parents and trashed = false"])
    """

    tags = Database.all(Tag)

    template = render_template(files: files, tags: tags, user: user)

    conn |> send_resp(:ok, template)
  end

  def last_modified_time(file) do
    case file.modified_time
    |> Timex.format("{relative}", :relative) do
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
