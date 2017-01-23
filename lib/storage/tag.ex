defmodule Storage.Tag do
  @type t :: Storage.Database.Tag.t

  defstruct %Storage.Database.Tag{}
    |> Map.from_struct
    |> Map.keys
end