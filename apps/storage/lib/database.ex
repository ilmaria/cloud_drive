use Amnesia

defdatabase Database do

  deftable Tag, [{:id, autoincrement},
                 :name,
                 :color] do

    @type t :: %Tag{
      id:       non_neg_integer,
      name:     String.t,
      color:    String.t
    }
  end

  deftable User, [{:id, autoincrement},
                  :email,
                  :name,
                  :password_hash,
                  :google_account] do

    @type t :: %User{
      id:                   non_neg_integer,
      email:                String.t,
      name:                 String.t,
      password_hash:        String.t,
      google_account:       String.t
    }
  end

  deftable File, [{:id, autoincrement},
                  :name,
                  :tags,
                  :mime_type,
                  :creation_time,
                  :modified_time,
                  :owner_id,
                  :edit_url,
                  :download_url,
                  :size,
                  :google_file?] do

    @type t :: %File{
      id:               non_neg_integer,
      name:             String.t,
      tags:             [non_neg_integer],
      mime_type:        String.t,
      creation_time:    DateTime.t,
      modified_time:    DateTime.t,
      owner_id:         non_neg_integer,
      edit_url:         String.t,
      download_url:     String.t,
      size:             non_neg_integer,
      google_file?:     boolean
    }
  end
end
