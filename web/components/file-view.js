import xs from 'xstream'
import {ul, li} from '@cycle/dom'
import isolate from '@cycle/isolate'


function filter(search$, data$) {
  return xs.combine(search$, data$)
    .map(([search, data]) => {
      const filteredFiles = data.files
        .filter(file => {
          file.name.startsWith(search)
        })
      return filteredFiles
    })
}

function view(files$) {
  return files$.map(files =>
    ul(
      files.map(file => {
        li(file.name)
      })
    )
  )
}

function FileView(input) {
  const search$ = input.search
  const data$ = input.data
  
  const files$ = filter(search$, data$)
  const view$ = view(files$)

  return {
    DOM: view$,
    value: files$
  }
}

const IsolatedFileView = function (input) {
  return isolate(FileView)(input)
}

export default IsolatedFileView
