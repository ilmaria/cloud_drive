defmodule CloudDrive.Template do
  @doc """
  
  """

  defmacro __using__(_opts) do
    quote do
      import CloudDrive.Template
      require EEx

      view_path = "./lib/views/"
      files = File.ls!(view_path)
      
      Enum.each files, fn file ->
        file_name = file |> String.split(".") |> List.first()
        render_func = "render_" <> file_name |> String.to_atom()

        EEx.function_from_file(:def,
          render_func, view_path <> file, [:assigns])
      end

      def render(file, bindings \\ []) do
        render_func = "render_" <> file |> String.to_atom()
        apply(__MODULE__, render_func, [bindings])
      end
    end
  end
  
end
