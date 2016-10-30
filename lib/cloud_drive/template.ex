defmodule CloudDrive.Template do

  defmacro __using__(_opts) do
    quote do
      require EEx

      view_path = "./lib/views/"
      files = File.ls!(view_path)
      
      Enum.each files, fn file ->
        render_func = file |> String.replace(".", "") |> String.to_atom
        EEx.function_from_string(
          :defp, render_func, view_path <> file, [:assigns])
      end
      
      def render(file, bindings \\ []) do
        render_func = file |> String.replace(".", "") |> String.to_atom
        apply(__MODULE__, render_func, [bindings])
      end
    end
  end

end
