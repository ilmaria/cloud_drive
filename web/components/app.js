import xs from 'xstream'
import {run} from '@cycle/xstream-run'
import {makeDOMDriver, h2, div} from '@cycle/dom'
import SearchBar from './search-bar'
import FileView from './file-view'

function App(input) {
  const searchBar = SearchBar(input)
  const fileData = xs.of({
    files: [
      {
        name: 'kissa.txt',
        id: 0,
        tags: [1, 3],
        modified_time: '2016-11-02'
      },
      {
        name: 'dogs.txt',
        id: 2,
        tags: [2],
        modified_time: '2016-11-02'
      }
    ],
    tags: [
      {
        id: 1,
        name: 'fun'
      },
      {
        id: 2,
        name: 'cool'
      },
      {
        id: 3,
        name: 'something'
      }
    ]
  })

  const fileView = FileView({search: searchBar.value, data: fileData})

  const view$ = xs.combine(searchBar.DOM, fileView.DOM)
    .map(([searchBarDOM, fileViewDOM]) => {
      div([
        searchBarDOM,
        fileViewDOM
      ])
    })

  return {
    DOM: view$
  }
}

const drivers = {
  DOM: makeDOMDriver('main')
}

run(App, drivers)
