mime = require 'mime'
require 'shelljs/global'

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