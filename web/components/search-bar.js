import xs from 'xstream'
import {section, span, input} from '@cycle/dom'
import isolate from '@cycle/isolate'

function action(input) {
  return input.DOM.select('.search-bar').events('input')
    .map(ev => ev.target.value)
}

function model(update$) {
  const initialSearch$ = xs.of('')

  return xs.merge(initialSearch$, update$).remember()
}

function view(model$) {
  return model$.map(model =>
    section({role: 'search'}, [
      input('.search-bar', {
        attrs: {type: 'search', model}
      })
    ])
  )
}

function SearchBar(input) {
  const action$ = action(input)
  const model$ = model(action$)
  const view$ = view(model$)

  return {
    DOM: view$,
    value: model$
  }
}

const IsolatedSearchBar = function (input) {
  return isolate(SearchBar)(input)
}

export default IsolatedSearchBar
