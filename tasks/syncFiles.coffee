request = require 'request'

module.exports = (grunt) ->
	getFilesFromWatch = () ->
		files = JSON.stringify grunt.config.get 'watch'
		files.match /"files":\[(.*?)\]/g

	readContentFromFile = (sources) ->
		for src in sources
			files = grunt.file.expand src
			for file in files
				content = grunt.file.read file;
				sendHttpRequest(file, content)

	sendHttpRequest = (path, content) ->
	  fileName = "speedbag\/"+path.replace /\\/g,"\/"
	  console.log path

	grunt.registerTask 'syncfiles', ->
		paths = getFilesFromWatch()
		for path in paths
			sources = path.match /src(.*?)(?=")/g
			readContentFromFile sources
	
