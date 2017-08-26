defmodule CloudDrive.Components.FileTable do
  use WebAssembly
  alias CloudDrive.Database.CloudFile

  def render(files) do
    table [class: "left-align"] do
      thead do
        tr do
          th "Name"
          th "View Link"
          th "Download"
          th "File Size"
          th "Last Modified"
        end
      end
      tbody do
        for file <- files do
          tr [id: "recent-file-id-#{file.id}"] do
            td do
              div Plug.HTML.html_escape_to_iodata(file.name)
              div do
                for tag <- file.tags do
                  span [style: "background-color: #{tag.color}"],
                  Plug.HTML.html_escape_to_iodata(tag.name)
                end
              end
            end
            td do
              a [href: file.view_url], "Open"
            end
            td do
              a [href: file.view_url], "Open"
            end
            td CloudFile.compact_size(file.size)
            td CloudFile.last_modified_time(file)
          end
        end
      end
    end
  end

end


