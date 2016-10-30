use Amnesia
alias CloudDrive.Hashids, as: H

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
      mime_type:      String.t,
      creation_time:  DateTime.t,
      modified_time:  DateTime.t,
      owner_id:       non_neg_integer,
      url:            String.t
    }

    # helper function to access the owning User
    @spec owner(%File{}) :: %User{}
    def owner(self) do
      User.read(self.owner_id)
    end
    
    @spec new(%File{}) :: %File{}
    def new(file) do
      Map.merge(%File{
        tags: [],
        url: "shared/#{H.encode(file.name)}/#{file.name}",
        creation_time: DateTime.utc_now,
        modified_time: DateTime.utc_now
      }, file)
    end
  end
  
end
