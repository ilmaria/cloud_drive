defmodule CloudDrive.Template do
  
  defmacro __using__(_opts) do
    quote do
      require EEx

      view_name = __MODULE__ 
      |> Atom.to_string
      |> String.downcase
      |> String.split(".")
      |> List.last

      EEx.function_from_file(
        :defp,
        :render_template,
        Path.join(__DIR__, view_name <> ".html.eex"),
        [:assigns])
    end
  end

end
