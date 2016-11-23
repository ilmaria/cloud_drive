defmodule CloudDrive.Template do

  defmacro __using__(_opts) do
    quote do
      require EEx

      view = Module.split(__MODULE__)
      |> List.last
      |> Macro.underscore

      path = __DIR__
      |> Path.join("#{view}/#{view}.html.eex")

      if File.exists? path do
        EEx.function_from_file(:defp, :render_template, path, [:assigns])
      end
    end
  end

end
