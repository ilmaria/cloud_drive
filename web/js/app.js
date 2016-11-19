'use strict'
const $ = document.querySelector.bind(document)
const $$ = document.querySelectorAll.bind(document)

//const = FILE_LIST // this is declared inline in index.html

const fuse = new Fuse(FILE_LIST, {
  keys: ['name', 'tags']
})
let selectedFiles = []

$('input[type="search"]').addEventListener('input', event => {
  const string = event.target.value
  const foundFiles = fuse.search(string)
  showSearchResults(foundFiles, string.length != 0)
})

const tableRows = $$('tbody tr')

tableRows.forEach(row => {
  row.addEventListener('click', event => {
    // remove old selected classes
    for (let i of tableRows) {
      i.classList.remove('selected')
    }
    // mark current row as selected
    row.classList.add('selected')
    selectedFiles = []
    selectedFiles.push(elemIdToFileId(row.id))
  })
})

function deleteSelectedFiles() {
  axios.post('/file-remove', {
    fileIds: selectedFiles
  })
  .then(resp => {
    location.reload()
  })
  .catch(err => {
    console.error(err)
  })
}

function showSearchResults(files, show) {
  // change header visibilities
  $('#search-results-h').classList.toggle('display-none', !show)
  $('#all-files-h').classList.toggle('display-none', show)
  $('#recent-files').classList.toggle('display-none', show)

  const tableRows = $$('#all-files tbody tr')

  for (let row of tableRows) {
    const fileId = elemIdToFileId(row.id)
    const inFileResults = files.find(x => x.id === fileId)

    if (show) {
      row.classList.toggle('display-none', !inFileResults)
    } else {
      row.classList.remove('display-none')
    }
  }
}

function elemIdToFileId(elemId) {
  return Number(elemId.split('-')[2])
}
