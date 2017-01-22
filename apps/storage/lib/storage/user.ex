defmodule Storage.User do
  @type t :: Database.User.t

  defstruct %Database.User{}
    |> Map.from_struct
    |> Map.keys
end
