defmodule CloudDrive.Database do

  defmacro __using__(opts) do
    quote do
      use Amnesia
      use CloudDrive.Database.Tables
      alias CloudDrive.Database.Tables, as: unquote(opts[:as])
    end
  end

end
