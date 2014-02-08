request = require 'request'
require 'shelljs/global'
watch = require 'watch'

module.exports = (grunt) ->
	
	watchFiles = () ->
		watch.createMonitor 'src', (monitor) ->
			monitor.on 'created', (file, stat) ->
				if grunt.file.isFile file
					console.log "eh um arquivo"
					content = cat file
					putHttpRequest file, content
				if grunt.file.isDir file
					console.log "eh um diretorio"
					grunt.file.recurse file, (abspath, rootdir, subdir, filename) ->
						if grunt.file.isFile abspath
							content = cat abspath
							putHttpRequest abspath , content 

			monitor.on 'removed', (file, stat) ->
				filePath = file.replace /\\/g,"\/"
				request.del {
					uri: "http://basedevmkp.vtexlocal.com.br:81/api/persistence/",
					json: {
						FilePath: filePath
		  	 	}
		  	 }, (error, response, body) ->
		  	 	if response.statusCode is 204 then console.log 'file '+filePath+' deleted'
		  	 	else grunt.log.warn 'Error ' + response.statusCode

			monitor.on 'changed', (file, curr, prev) ->
				content = cat file
				putHttpRequest file, content

	getFilesFromWatch = () ->
		files = JSON.stringify grunt.config.get 'watch'
		files.match /"files":\[(.*?)\]/g

	readContentFromFile = (sources) ->
		for src in sources
			files = grunt.file.expand src
			for file in files
				if grunt.file.isFile file
					content = grunt.file.read file
					putHttpRequest(file, content)

	putHttpRequest = (file, content) ->
		filePath = file.replace /\\/g,"\/"
		request.put {
			uri: "http://basedevmkp.vtexlocal.com.br:81/api/persistence/",
			json: {
				FilePath: filePath,
				Content: content
			}
		}, (error, response, body) ->
			if response.statusCode is 200 then console.log 'sync file: ' + filePath

	deleteHttpRequest = () ->
		console.log "delete"
		request.del {
			uri: "http://basedevmkp.vtexlocal.com.br:81/api/persistence/",
			json: {
				FilePath: 'src/'
			}
		}, (error, response, body) ->
			if response.statusCode is 204
				console.log "Status code 204"
				paths = getFilesFromWatch()
				for path in paths
					sources = path.match /src(.*?)(?=")/g
					readContentFromFile sources

	grunt.registerTask 'syncfiles', ->
		deleteHttpRequest()
		watchFiles()


	
