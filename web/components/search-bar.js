import xs from 'xstream'
import {section, span, input} from '@cycle/dom'
import isolate from '@cycle/isolate'

function update(input) {
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
  const update$ = update(input)
  const model$ = model(update$)
  const vtree$ = view(model$)

  return {
    DOM: vtree$,
    value: model$
  }
}

const IsolatedSearchBar = function (input) {
  return isolate(SearchBar)(input)
}

export default IsolatedSearchBar
