mime = require 'mime'
require 'shelljs/global'
mypath = require 'path'

getPatternFrom = (key) -> 		
	key = key.replace /\\/g, "\\\\"
	return pattern = /// ^(#{key}\\) ///

getOnlyDirectories = (changedFiles) ->
	directories = {}
	for key, value of changedFiles
		if value is 'removed'
			if mypath.extname(key) is ''
				directories[key] = value
	return directories

exports.fileAlreadyAdded = (changedFiles, filePath) ->
	directories = getOnlyDirectories changedFiles
	for key , value of directories
		pattern = getPatternFrom key
		return true if pattern.test(filePath) is true
	return false

exports.getCredentials = ->
	path = 'tasks/auth.json'
	return null	if !test('-f', path)

	file = cat path
	return JSON.parse(file)

exports.createJsonMessage = (path, changedFiles) ->
	action: changedFiles[path]
	path: this.formatPath path
	content_type: mime.lookup path
	content: this.getFileContentBase64 path

exports.getFileContentBase64 = (path) ->
	if test '-f', path
		content = cat path
		return new Buffer(content || '').toString('base64')

exports.getFileContentAscii = (content) ->
	return new Buffer(content, 'base64').toString('ascii')

exports.formatPath = (file) ->
	return file.replace /\\/g,"\/"