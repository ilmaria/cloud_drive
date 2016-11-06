const $ = document.querySelector.bind(document)
const $$ = document.querySelectorAll.bind(document)

const fileTemplate = $('#file-item-template').content
const data = {}

function updateFileList(files) {
  const fileList = $('#search-files')

  for (let file of files) {
    const fileItem = document.importNode(fileTemplate, true)
    fileItem.querySelector('li').textContent = file.name
    fileList.appendChild(fileItem)
  }

  fileList.classList.toggle('display-none', files.length == 0)
}

//updateFileList(data.files)
