defmodule CloudDrive.Storage.Tag do
    @type t :: %__MODULE__{
        id:       non_neg_integer,
        name:     String.t,
        color:    String.t,
    }

    defstruct [:id, :name, :color]
end