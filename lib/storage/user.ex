defmodule Storage.User do
  @type t :: Storage.Database.User.t

  defstruct %Storage.Database.User{}
    |> Map.from_struct
    |> Map.keys
end
