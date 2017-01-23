defmodule CloudDrive.View do

  defmacro __using__(_opts) do
    quote do
      use Plug.Router
      use CloudDrive.Template

      plug :match
      plug :dispatch

      defp redirect(conn, opts) do
        url = opts[:to]
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
