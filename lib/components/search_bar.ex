defmodule CloudDrive.Components.SearchBar do
  use WebAssembly

  def render() do
    builder do
      section [id: :file_search, role: "search"] do
        h3 [class: "mb0 center"], "Search"
        div [class: "flex", style: "width: 100%"] do
          input [type: "search", class: "width: 35rem"]
        end
      end
    end
  end

end