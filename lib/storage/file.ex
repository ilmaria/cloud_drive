defmodule CloudDrive.Storage.File do
    @type t :: %__MODULE__{
        id:             String.t,
        name:           String.t,
        tags:           [non_neg_integer],
        mime_type:      String.t,
        created_time:   DateTime.t,
        modified_time:  DateTime.t,
        owner_email:    String.t,
        url:            String.t,
        size:           non_neg_integer,
        location:       atom,
    }

    defstruct [:id, :name, :tags, :mime_type, :created_time,
        :modified_time, :owner_email, :url, :size, :location]

    @spec from(any(), String.t, [non_neg_integer]) :: %__MODULE__{}
    def from(file_info, user_email, tags \\ [])

    @spec from(%Plug.Upload{}, String.t, [non_neg_integer]) :: %__MODULE__{}
    def from(%Plug.Upload{} = file_info, user_email, tags) do
        %__MODULE__{
            id:             Path.basename(file_info.path),
            name:           file_info.filename,
            tags:           tags,
            mime_type:      file_info.content_type,
            created_time:   DateTime.utc_now,
            modified_time:  DateTime.utc_now,
            owner_email:    user_email,
            url:            "",
            size:           File.stat!(file_info.path).size,
            location:       :local,
        }
    end

    @spec from(any(), String.t, [non_neg_integer]) :: %__MODULE__{}
    def from(file_info, user_email, tags) do
        %__MODULE__{
            id:             file_info["id"],
            name:           file_info["name"],
            tags:           tags,
            mime_type:      file_info["mimeType"],
            created_time:   file_info["createdTime"],
            modified_time:  file_info["modifiedTime"],
            owner_email:    user_email,
            url:            file_info["webViewLink"],
            size:           file_info["size"],
            location:       :google_drive,
        }
    end
end