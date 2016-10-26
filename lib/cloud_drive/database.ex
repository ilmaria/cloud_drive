use Amnesia

defdatabase CloudDrive.Database do
  
  deftable User, [{:id, autoincrement}, :username, :password] do
    @type t :: %User{
      id:         non_neg_integer,
      username:   String.t,
      password:   String.t
    }
  end

  deftable File, [{:id, autoincrement}, :name, :tags, :mime_type,
                  :creation_time, :modified_time, :owner_id, :url] do
    @type t :: %File{
      id:             non_neg_integer,
      name:           String.t,
      tags:           [String.t],
      mime_type:      String.t
      creation_time:  DateTime.t,
      modified_time:  DateTime.t,
      owner_id:       non_neg_integer,
      url:            String.t
    }

    @default_values %{
      tags:           [],
      mime_type:      :"text/plain"
      creation_time:  DateTime.utc_now,
      modified_time:  DateTime.utc_now
    }

    # helper function to access the owning User
    def owner(self) do
      User.read(self.owner_id)
    end

    def create(file) do
      url = "shared/random/" <> file[:name]
      file |> Map.merge(@default_values)
           |> Map.merge(%{url: url})
  end

end
