defmodule Auth.Error do
  @behaviour Guardian.Plug.ErrorHandler

  def unauthenticated(conn, _params) do
    conn |> redirect(to: "/login")
  end

end
