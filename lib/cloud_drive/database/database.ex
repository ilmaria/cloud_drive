use Amnesia
alias CloudDrive.Hashids, as: H
alias CloudDrive.Database, as: Db

defdatabase Db do

  deftable Db.Tag, [{:id, autoincrement}, :name, :color] do
    @type t :: %Db.Tag{
      id:       non_neg_integer,
      name:     String.t,
      color:    String.t
    }
  end

  deftable Db.File, [{:id, autoincrement}, :name, :tags, :mime_type,
                  :creation_time, :modified_time, :owner_id, :url] do
    @type t :: %Db.File{
      id:             non_neg_integer,
      name:           String.t,
      tags:           [Db.Tag.t],
      mime_type:      String.t,
      creation_time:  DateTime.t,
      modified_time:  DateTime.t,
      owner_id:       non_neg_integer,
      url:            String.t
    }

    # helper function to access the owning User
    @spec owner(Db.File.t) :: Db.User.t
    def owner(self) do
      Db.User.read(self.owner_id)
    end
    
    @spec save(Db.File.t, Plug.Upload.t) :: Db.File.t
    def save(opts, file) do
      # create file first to get auto incremented id
      cloud_file = Map.merge(%Db.File{
        tags: [],
        url: "",
        creation_time: DateTime.utc_now,
        modified_time: DateTime.utc_now,
        name: file.filename,
        mime_type: file.content_type
      }, opts) |> Db.File.write

      # we use hashed id for file name and shared url
      hash = H.encode(cloud_file.id)

      File.cp(file.path, "/user_files/#{hash}")
      
      %{cloud_file | url: "/shared/#{hash}/#{file.filename}"}
        |> Db.File.write
    end
  end

  deftable Db.User, [{:id, autoincrement}, :username, :password] do
    @type t :: %Db.User{
      id:         non_neg_integer,
      username:   String.t,
      password:   String.t
    }
  end
  
end
