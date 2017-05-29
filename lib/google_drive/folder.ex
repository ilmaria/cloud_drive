defmodule CloudDrive.GoogleDrive.Folder do
  @type t :: %__MODULE__{
    name: String.t,
    id:   String.t
  }

  defstruct [:name, :id]
end
