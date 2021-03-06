use Amnesia
alias CloudDrive.Hashids, as: H
alias CloudDrive.GoogleDrive

require Logger

defdatabase CloudDrive.Database do

    deftable Tag, [:user_id, :name, :color], type: :bag do
        @type t :: %__MODULE__{
            user_id:    non_neg_integer,
            name:       String.t,
            color:      String.t,
        }

        def new(user, name, color) do
            %__MODULE__{
                user_id: user.id,
                name: name,
                color: color,
            }
        end
    end

    deftable User, [{:id, autoincrement}, :email, :password_hash,
                    :google_synced, :refresh_token, :access_token, :token_expiration] do
        @type t :: %__MODULE__{
            id:               non_neg_integer,
            email:            String.t,
            password_hash:    String.t,
            google_synced:    boolean,
            refresh_token:    String.t,
            access_token:     String.t,
            token_expiration: non_neg_integer,
        }
    end

    deftable CloudFile, [:id, :name, :tags, :mime_type, :created_time, :size,
                         :modified_time, :owner_id, :download_url, :view_url] do
        @type t :: %__MODULE__{
            id:             String.t,
            name:           String.t,
            tags:           [Tag.t],
            mime_type:      String.t,
            created_time:   DateTime.t,
            modified_time:  DateTime.t,
            owner_id:       non_neg_integer,
            download_url:   String.t,
            view_url:       String.t,
            size:           non_neg_integer,
        }

        @app_settings Application.get_env(:cloud_drive, :settings)

        def from(file, user, tags \\ [])

        @spec from(Plug.Upload.t, User.t, [Tag.t]) :: t
        def from(%Plug.Upload{} = file, user, tags) do
            file_size = case File.stat(file.path) do
                {:ok, file_info} -> file_info.size
                _ -> nil
            end

            %__MODULE__{
                id: Path.basename(file.path),
                name: file.filename,
                tags: tags,
                mime_type: file.content_type,
                created_time: DateTime.utc_now,
                modified_time: DateTime.utc_now,
                owner_id: user.id,
                download_url: "",
                view_url: "",
                size: file_size,
            }
        end

        @spec from(map, User.t, [Tag.t]) :: t
        def from(%{} = file, user, tags) do
            created_time = case Timex.parse(file["createdTime"], "{ISO:Extended:Z}") do
                {:ok, time} -> time
                _ -> nil
            end

            modified_time = case Timex.parse(file["modifiedTime"], "{ISO:Extended:Z}") do
                {:ok, time} -> time
                _ -> nil
            end

            %__MODULE__{
                id: file["id"],
                name: file["name"],
                tags: tags,
                mime_type: file["mimeType"],
                created_time: created_time,
                modified_time: modified_time,
                owner_id: user.id,
                download_url: "",
                view_url: file["webViewLink"],
                size: file["size"],
            }
        end

        @spec write_to_disk(t, Path.t) :: none
        def write_to_disk(file, from_path) do
            shared_url = @app_settings[:shared_url]
            shared_folder = @app_settings[:shared_files_folder]

            File.mkdir(shared_folder)
            File.cp(from_path, shared_folder <> file.id)

            %{file | download_url: "/#{shared_url}/#{file.id}/#{file.name}"}
                |> __MODULE__.write
        end

        @spec delete_from_disk(t) :: none
        def delete_from_disk(file_id) do
            shared_folder = @app_settings[:shared_files_folder]
            File.rm(shared_folder <> file_id)

            __MODULE__.delete(file_id)
        end

        @spec last_modified_time(t) :: String.t
        def last_modified_time(file) do
            case file.modified_time |> Timex.format("{YYYY}-{0M}-{0D}") do
                {:ok, time} -> time
                {:error, reason} ->
                    Logger.error inspect(reason, pretty: true)
                    "-"
            end
        end

        @spec compact_size(non_neg_integer) :: String.t
        def compact_size(nil), do: "-"
        def compact_size(file_size) do
            Sizeable.filesize(file_size, %{round: 1})
        end
    end
end
