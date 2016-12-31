use Amnesia
alias CloudDrive.Hashids, as: H
alias CloudDrive.GoogleDrive

defdatabase CloudDrive.Database.Tables do

  deftable Tag, [{:id, autoincrement}, :name, :color] do
    @type t :: %Tag{
      id:       non_neg_integer,
      name:     String.t,
      color:    String.t
    }

    def save(tag, _opts) do
      write(tag)
    end
  end

  deftable User, [{:id, autoincrement}, :email, :name, :password_hash,
                  :google_refresh_token] do
    @type t :: %User{
      id:                   non_neg_integer,
      email:                String.t,
      name:                 String.t,
      password_hash:        String.t,
      google_refresh_token: String.t
    }

    def save(user, _opts) do
      write(user)
    end
  end

  deftable CloudFile, [{:id, autoincrement}, :name, :tags, :mime_type,
                       :creation_time, :modified_time, :owner_id, :url,
                       :size, :location] do
    @type t :: %CloudFile{
      id:             non_neg_integer,
      name:           String.t,
      tags:           [Tag.t],
      mime_type:      String.t,
      creation_time:  DateTime.t,
      modified_time:  DateTime.t,
      owner_id:       non_neg_integer,
      url:            String.t,
      size:           non_neg_integer,
      location:       atom
    }

    @user_files "user_files/"
    @shared_url "shared"

    @doc"""
    A helper function to access the owner.
    """
    def owner(self) do
      User.read(self.owner_id)
    end

    @doc"""
    Update an existing file on the database.
    """
    def update(file, opts \\ []) do
      user = opts |> Keyword.get(:user)
      tags = opts |> Keyword.get(:tags, [])

      [matched_files] = CloudFile.match(
        owner_id: user.id,
        name: file.filename,
        tags: tags
      ) |> Amnesia.Selection.values

      case matched_files do
        [file_to_update] -> file_to_update
        nil -> {:error, :no_such_file}
        _ -> raise "Found multiple files with same name and tags"
      end
    end

    @doc"""
    Transform file to CloudFile struct.
    """
    def from_file(%Plug.Upload{} = file, opts) do
      user = opts |> Keyword.get(:user)
      tags = opts |> Keyword.get(:tags, [])

      %CloudFile{
        owner_id: user.id,
        tags: tags,
        name: file.filename,
        url: "",
        size: File.stat!(file.path).size,
        creation_time: DateTime.utc_now,
        modified_time: DateTime.utc_now,
        mime_type: file.content_type,
        location: :cloud_drive
      }
    end

    def from_file(%GoogleDrive.File{} = file, opts) do
      user = opts |> Keyword.get(:user)
      tags = opts |> Keyword.get(:tags, [])

      %CloudFile{
        owner_id: user.id,
        tags: tags,
        name: file.name,
        url: file.webViewLink,
        size: file.size,
        creation_time: file.createdTime,
        modified_time: file.modifiedTime,
        mime_type: file.mimeType,
        location: :google_drive
      }
    end

    @doc"""
    Save a new file to the database.
    """
    def save(file, opts \\ [])

    def save(%Plug.Upload{} = file, opts) do
      cloud_file = file |> from_file(opts) |> CloudFile.write

      File.mkdir(@user_files)

      # we use hashed id for file name and shared url
      hash = H.encode(cloud_file.id)

      File.cp!(file.path, @user_files <> hash)

      %{cloud_file | url: "/#{@shared_url}/#{hash}/#{file.filename}"}
      |> CloudFile.write
    end

    def save(%GoogleDrive.File{} = file, opts) do
      file |> from_file(opts) |> CloudFile.write
    end

    def remove(fileId) do
      File.rm!(@user_files <> H.encode(fileId))

      CloudFile.delete(fileId)
    end
  end

  def get_or_create_tag(tag_name) do
    Amnesia.transaction do
      match = Tag.match(name: tag_name)
      |> Amnesia.Selection.values

      case match do
        [first|_] -> first
        [] ->  %Tag{name: tag_name} |> Tag.write
      end
    end
  end

  def create_or_update_file(%GoogleDrive.File{} = file, user, tags) do
    Amnesia.transaction do
      existing_file = CloudFile.match(
        name: file.name, user_id: user.id, tags: tags)
        |> Amnesia.Selection.values
        |> List.first

      if existing_file do
        updated_file = file
        |> CloudFile.from_file(user: user, tags: tags)
        |> Map.from_struct
        |> Map.merge(%{id: existing_file.id})

        struct!(CloudFile, updated_file) |> CloudFile.write
      else
        CloudFile.save(file, user: user, tags: tags)
      end
    end
  end

  defmacro all(table) do
    quote do
      Amnesia.transaction do
        unquote(table).where(true) |> Amnesia.Selection.values
      end
    end
  end

  defmacro where(table, query) do
    quote do
      Amnesia.transaction do
        unquote(table).where(unquote(query)) |> Amnesia.Selection.values
      end
    end
  end

  defmacro match(table, query) do
    quote do
      Amnesia.transaction do
        unquote(table).match(unquote(query)) |> Amnesia.Selection.values
      end
    end
  end

  defmacro get(table, query) do
    quote do
      Amnesia.transaction do
        unquote(table).match(unquote(query))
        |> Amnesia.Selection.values
        |> List.first
      end
    end
  end

  defmacro save(table, value, opts \\ []) do
    quote do
      Amnesia.transaction do
        unquote(table).save(unquote(value), unquote(opts))
      end
    end
  end

  defmacro remove(table, item) do
    quote do
      Amnesia.transaction do
        unquote(table).remove(unquote(item))
      end
    end
  end

end
