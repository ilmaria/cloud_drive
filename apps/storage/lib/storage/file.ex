defmodule Storage.File do
  @type t :: Database.File.t

  defstruct %Database.File{}
    |> Map.from_struct
    |> Map.keys
end
