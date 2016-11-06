use Amnesia
alias CloudDrive.Hashids, as: H

defdatabase CloudDrive.Database do

  deftable Tag, [{:id, autoincrement}, :name, :color] do
    @type t :: %Tag{
      id:       non_neg_integer,
      name:     String.t,
      color:    String.t
    }
  end
  
  deftable User, [{:id, autoincrement}, :username, :password] do
    @type t :: %User{
      id:         non_neg_integer,
      username:   String.t,
      password:   String.t
    }
  end

  deftable CloudFile, [{:id, autoincrement}, :name, :tags, :mime_type,
                  :creation_time, :modified_time, :owner_id, :url] do
    @type t :: %CloudFile{
      id:             non_neg_integer,
      name:           String.t,
      tags:           [Tag.t],
      mime_type:      String.t,
      creation_time:  DateTime.t,
      modified_time:  DateTime.t,
      owner_id:       non_neg_integer,
      url:            String.t
    }

    # helper function to access the owning User
    @spec owner(CloudFile.t) :: User.t
    def owner(self) do
      User.read(self.owner_id)
    end
    
    @spec save(CloudFile.t, Plug.Upload.t) :: CloudFile.t
    def save(file, opts \\ []) do
      user = opts |> Keyword.get(:user)
      tags = opts |> Keyword.get(:tags, [])
      
      # create file first to get auto incremented id
      cloud_file = %CloudFile{
        owner_id: user.id,
        tags: tags,
        url: "",
        creation_time: DateTime.utc_now,
        modified_time: DateTime.utc_now,
        name: file.filename,
        mime_type: file.content_type
      } |> CloudFile.write

      # root directory for user files
      root = "user_files/"
      File.mkdir(root)
      
      # we use hashed id for file name and shared url
      hash = H.encode(cloud_file.id)
      
      File.cp(file.path, root <> hash)
      
      %{cloud_file | url: "/shared/#{hash}/#{file.filename}"}
        |> CloudFile.write
    end
  end
  
end
