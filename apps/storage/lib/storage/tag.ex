defmodule Storage.Tag do
  @type t :: Database.Tag.t

  defstruct %Database.Tag{}
    |> Map.from_struct
    |> Map.keys
end