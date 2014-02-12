require 'shelljs/global'
request = require 'request'
watch = require 'watch'
_ = require 'lodash'
util = require './lib/util'

module.exports = (grunt) ->
	changedFiles = Object.create null

	onChange = _.debounce((changedFiles) ->
		requestMessage = createRequestMessage changedFiles
		request.put {
			uri: "http://basedevmkp.vtexlocal.com.br:81/api/persistence/",
		}, (error, response, body) ->
			cleanChangedFiles()
	, 200)
	
	syncFilesToS3 = () ->
		changedFiles['src'] = 'removed'
		onChange changedFiles

	watchFiles = () ->
		watch.createMonitor 'src', (monitor) ->
			monitor.on 'created', (filePath) ->
				changedFiles[filePath] = 'created'
				onChange changedFiles

			monitor.on 'removed', (filePath) ->
				changedFiles[filePath] = 'removed'
				onChange changedFiles

			monitor.on 'changed', (filePath) ->
				changedFiles[filePath] = 'changed'
				onChange changedFiles

	createRequestMessage = (changedFiles) ->	
		messages = []
		for path in Object.keys changedFiles
			messages.push util.createJsonMessage path, changedFiles
		return messages

	cleanChangedFiles = () ->
		changedFiles = Object.create null

	grunt.registerTask 'syncfiles', ->
		syncFilesToS3()
		watchFiles()