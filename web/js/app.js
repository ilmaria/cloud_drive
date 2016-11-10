const $ = document.querySelector.bind(document)
const $$ = document.querySelectorAll.bind(document)

const files = FILE_LIST
const fuse = new Fuse(files, {
  keys: ['name', 'tags']
})
const fileItemTemplate = $('#all-files tbody tr').cloneNode(true)

$('input[type="search"]').addEventListener('input', event => {
  const string = event.target.value
  const foundFiles = fuse.search(string)
  updateFileList(foundFiles)
  showSearchResults(string.length > 0)
})

function updateFileList(files) {
  const fileList = $('#searched-files tbody')
  
  removeChildren(fileList)

  for (let file of files) {
    const fileItem = fileItemTemplate.cloneNode(true)
    const [fileName, fileSize, lastModified] = fileItem.querySelectorAll('td')
    fileName.textContent = file.name
    fileSize.textContent = file.name
    lastModified.textContent = file.modified_time
    fileList.appendChild(fileItem)
  }
}

function showSearchResults(show) {
  $('#searched-files').classList.toggle('display-none', !show)
  $('#recent-files').classList.toggle('display-none', show)
  $('#all-files').classList.toggle('display-none', show)
}

function removeChildren(node) {
  while(node.firstChild) {
    node.removeChild(node.firstChild)
  }
}
