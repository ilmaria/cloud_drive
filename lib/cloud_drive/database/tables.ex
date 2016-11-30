use Amnesia
alias CloudDrive.Hashids, as: H

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

  deftable User, [{:id, autoincrement}, :email, :name, :password_hash] do
    @type t :: %User{
      id:             non_neg_integer,
      email:          String.t,
      name:           String.t,
      password_hash:  String.t
    }

    def save(user, _opts) do
      write(user)
    end
  end

  deftable CloudFile, [{:id, autoincrement}, :name, :tags, :mime_type,
                  :creation_time, :modified_time, :owner_id, :url, :size] do
    @type t :: %CloudFile{
      id:             non_neg_integer,
      name:           String.t,
      tags:           [Tag.t],
      mime_type:      String.t,
      creation_time:  DateTime.t,
      modified_time:  DateTime.t,
      owner_id:       non_neg_integer,
      url:            String.t,
      size:           non_neg_integer
    }

    @user_files "user_files/"
    @shared_url "shared"

    @doc"""
    A helper function to access the owning User.
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
    Save a new file to the database.
    """
    def save(%Plug.Upload{} = file, opts \\ []) do
      user = opts |> Keyword.get(:user)
      tags = opts |> Keyword.get(:tags, [])

      # create file first to get auto incremented id
      cloud_file = %CloudFile{
        owner_id: user.id,
        tags: tags,
        url: "",
        size: File.stat!(file.path).size,
        creation_time: DateTime.utc_now,
        modified_time: DateTime.utc_now,
        name: file.filename,
        mime_type: file.content_type
      } |> CloudFile.write

      File.mkdir(@user_files)

      # we use hashed id for file name and shared url
      hash = H.encode(cloud_file.id)

      File.cp!(file.path, @user_files <> hash)

      %{cloud_file | url: "/#{@shared_url}/#{hash}/#{file.filename}"}
      |> CloudFile.write
    end

    def save(%GoogleDrive.File{} = file, opts \\ []) do
      user = opts |> Keyword.get(:user)
      tags = opts |> Keyword.get(:tags, [])

      cloud_file = %CloudFile{
        owner_id: user.id,
        tags: tags,
        url: "",
        size: File.stat!(file.path).size,
        creation_time: DateTime.utc_now,
        modified_time: DateTime.utc_now,
        name: file.filename,
        mime_type: file.content_type
      } |> CloudFile.write
    end

    def remove(fileId) do
      File.rm!(@user_files <> H.encode(fileId))

      CloudFile.delete(fileId)
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
