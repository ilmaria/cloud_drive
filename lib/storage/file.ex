defmodule CloudDrive.Storage.Tag do
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
        :modified_time, :owner_id, :url, :size, :location]
end