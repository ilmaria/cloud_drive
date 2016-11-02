'use strict'

const fileTemplate = document.querySelector('#file-item-template').content
const data = {
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
}

function updateFileList(files) {
  const fileList = document.querySelector('#search-files')

  for (let file of files) {
    const fileItem = document.importNode(fileTemplate, true)
    fileItem.querySelector('li').textContent = file.name
    fileList.appendChild(fileItem)
  }

  fileList.classList.toggle('display-none', files.length == 0)
}

updateFileList(data.files)
