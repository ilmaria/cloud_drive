defmodule Storage.File do
  @type t :: Storage.Database.File.t

  defstruct %Storage.Database.File{}
    |> Map.from_struct
    |> Map.keys
end
