defmodule CloudDrive.Template do
  
  defmacro __using__(_opts) do
    quote do
      require EEx
      require Logger
      template_file = __MODULE__ 
        |> Atom.to_string
        |> String.downcase
        |> String.split(".")
        |> List.last

      Logger.debug template_file

      EEx.function_from_file(:defp,
        :render_template, "lib/cloud_drive/views/" <> template_file <> ".html.eex",
        [:assigns])
    end
  end

end
