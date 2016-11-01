import xs from 'xstream'
import {run} from '@cycle/xstream-run'
import {makeDOMDriver, h2, div} from '@cycle/dom'
import SearchBar from './search-bar'

function App(input) {
  const searchBar = SearchBar(input)
  
  const view$ = searchBar.DOM

  return {
      DOM: view$
  }
}

const drivers = {
  DOM: makeDOMDriver('main')
}

run(App, drivers)
