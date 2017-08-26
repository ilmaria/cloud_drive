defmodule CloudDrive.Components.Nav do
  use WebAssembly

  def render(user) do
    nav do
      if user do
        span "You are signed in as #{user.email}"
        text " | "
        form [action: "/auth/logout", method: "post", class: "inline-block"] do
          button [class: "link-btn"], "Logout"
        end
      else
        a [href: "/auth/google"], "Sign in with Google"

      end
      text " | "
      a [href: "/file/add"], "Add files"
      text " | "
      button [class: "link-btn"], "Delete file"
    end
  end

end