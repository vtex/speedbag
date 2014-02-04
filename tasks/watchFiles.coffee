request = require 'request'
require 'shelljs/global'

module.exports = (grunt) ->
	grunt.registerTask "watchFiles", ->
		console.log "Watching files . . ."

	changedFiles = Object.create(null)
	grunt.event.on "watch", (action, filepath) ->
	  changedFiles[filepath] = action
	  onChange()

	onChange = grunt.util._.debounce(->
	  Object.keys(changedFiles).forEach (file) ->
		  action = changedFiles[file]
		  if action is "deleted"
		  	 request.del {
		  	 	uri: "http://basedevmkp.vtexlocal.com.br:81/api/persistence/",
		  	 	json: {
		  	 		FilePath: file
		  	 	}
		  	 }, (error, response, body) ->
		  	 	if response.statusCode is 204 then console.log 'file deleted'
		  	 	else
		  	 		console.log "error: " + response.statusCode + "body: " + body

		  if action in ['added', 'created', 'renamed']
			  fileContent = cat file
			  request.put {
			  		uri: "http://basedevmkp.vtexlocal.com.br:81/api/persistence/",
					json: {
						FilePath: file,
						Content: fileContent
						}
					}, (error, response, body) ->
						if response.statusCode is 200 then console.log 'file saved'
						else
							console.log 'error: '+ response.statusCode + "body: " + body

	  changedFiles = Object.create(null)
	, 300)