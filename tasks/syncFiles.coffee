request = require 'request'

module.exports = (grunt) ->
	getFilesFromWatch = () ->
		files = JSON.stringify grunt.config.get 'watch'
		files.match /"files":\[(.*?)\]/g

	readContentFromFile = (sources) ->
		for src in sources
			files = grunt.file.expand src
			for file in files
				content = grunt.file.read file
				sendHttpRequest(file, content)

	sendHttpRequest = (path, content) ->
		request.put {
			uri: "http://basedevmkp.vtexlocal.com.br:81/api/persistence/",
			json: {
				FilePath: path,
				Content: content
			}
		}, (error, response, body) ->
			if response.statusCode is 200 then console.log 'sync file: ' + path

	grunt.registerTask 'syncfiles', ->
		paths = getFilesFromWatch()
		for path in paths
			sources = path.match /src(.*?)(?=")/g
			readContentFromFile sources
	
