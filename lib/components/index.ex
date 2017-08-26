defmodule CloudDrive.Components.Index do
  use WebAssembly

  def render(user, files) do
    builder do
      html [lang: "en"] do
        head do
          meta [charset: "utf-8"]
          meta [name: "viewport", content: "width=device-width, initial-scale=1"]
          meta [name: "description", content: "My cloud drive"]
          meta [name: "author", content: "Ilmari Autio"]
          title "CloudDrive"

          # Styles
          link [href: "/static/css/basscss.css", rel: "stylesheet"]
          link [href: "/static/css/app.css", rel: "stylesheet"]

          # Scripts
          script [src: "/static/libs/fuse.min.js", defer: true], []
          script [src: "/static/libs/axios.min.js", defer: true], []
          script [src: "/static/js/app.js", defer: true], []
        end
        body do
          main [class: "flex flex-column items-center"] do
            h1 "Cloud Drive"

            CloudDrive.Components.Nav.render(user)
            CloudDrive.Components.SearchBar.render()

            div [class: "m3 self-stretch"] do
              recent_files = Enum.take(files, 4)
              section [id: :recent_files] do
                h2 "Recent Files"
                CloudDrive.Components.FileTable.render(recent_files)
              end
              section [id: :all_files] do
                h2 "All Files"
                CloudDrive.Components.FileTable.render(files)
              end
            end
          end
        end
      end
    end
  end

end
