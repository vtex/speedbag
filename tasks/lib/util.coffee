mime = require 'mime'
require 'shelljs/global'

exports.createJsonMessage = (path, changedFiles) ->
    file = {}
    file.action = changedFiles[path]
    file.path = path
    file.content_type = mime.lookup path
    file.content = this.getFileContent path
    JSON.stringify file

exports.getFileContent = (path) ->
    if test '-f', path then content = cat path
    new Buffer(content || '').toString 'base64'