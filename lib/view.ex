defmodule CloudDrive.View do

  defmacro __using__(_opts) do
    quote do
      use Plug.Router
      require EEx

      plug :match
      plug :dispatch

      view = Module.split(__MODULE__)
          |> List.last()
          |> Macro.underscore()

      path = __DIR__ |> Path.join("#{view}.html.eex")

      if File.exists? path do
          EEx.function_from_file(:defp, :render_template, path, [:assigns])
      end

      defp redirect(conn, url) do
        body = """
        <!DOCTYPE html>
        You are being <a href="#{url}>redirected</a>.
        """

        conn
        |> put_resp_header("location", url)
        |> send_resp(conn.status || :found, body)
      end

      #defp put_message(conn, message) do
      #  messages = conn.assigns[:messages]
      #
      #  conn |> assign(:messages,
      #    case messages do
      #      nil -> [message]
      #      list -> [message | list]
      #    end)
      #end
    end
  end

end
