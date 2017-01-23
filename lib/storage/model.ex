defmodule Storage.Model do
  defmacro __using__() do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end
end
