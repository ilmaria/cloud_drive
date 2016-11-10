const $ = document.querySelector.bind(document)
const $$ = document.querySelectorAll.bind(document)

const files = FILE_LIST
const fuse = new Fuse(files, {
  keys: ['name', 'tags']
})

$('input[type="search"]').addEventListener('input', event => {
  const string = event.target.value
  const foundFiles = fuse.search(string)
  showSearchResults(foundFiles, string.length != 0)
})

function showSearchResults(files, show) {
  // change header visibilities
  $('#search-results-h').classList.toggle('display-none', !show)
  $('#all-files-h').classList.toggle('display-none', show)
  $('#recent-files').classList.toggle('display-none', show)

  const tableRows = $$('#all-files tbody tr')

  for (let row of tableRows) {
    const fileId = Number(row.id.split('-')[2])
    const inFileResults = files.find(x => x.id === fileId)
    
    if (show) {
      row.classList.toggle('display-none', !inFileResults)
    } else {
      row.classList.remove('display-none')
    }
  }
}
