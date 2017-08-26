defmodule CloudDrive.Components.SearchBar do
  use WebAssembly

  def render() do
    section [id: "file-search", role: "search"] do
      h3 [class: "mb0 center"], "Search"
      div [class: "flex", style: "width: 100%"] do
        input [type: "search", id: "main-search"]
      end
    end
  end

end