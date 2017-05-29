defmodule CloudDrive.Storage.Tag do
    @type t :: %__MODULE__{
        email:                String.t,
        password_hash:        String.t,
        google_refresh_token: String.t,
        gdrive_synced:        boolean,
    }

    defstruct [:email, :password_hash, :google_refresh_token, :gdrive_synced]
end