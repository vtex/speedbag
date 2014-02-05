request = require 'request'
require 'shelljs/global'

module.exports = (grunt) ->
	grunt.registerTask "watch files", ->
		console.log "Watching files . . ."

	changedFiles = Object.create(null)
	grunt.event.on "watch", (action, filepath) ->
	  changedFiles[filepath] = action
	  onChange()

	onChange = grunt.util._.debounce(->
	  Object.keys(changedFiles).forEach (file) ->
		  action = changedFiles[file]
		  fileName = "speedbag\/"+file.replace /\\/g,"\/"
		  if action is "deleted"
		  	 request.del {
		  	 	uri: "http://basedevmkp.vtexlocal.com.br:81/api/persistence/",
		  	 	json: {
		  	 		FilePath: fileName
		  	 	}
		  	 }, (error, response, body) ->
		  	 	if response.statusCode is 204 then console.log 'file deleted'
		  	 	else
		  	 		grunt.log.warn 'Error ' + response.statusCode

		  if action in ['added', 'created', 'renamed', 'changed']
			  fileContent = cat file
			  request.put {
			  		uri: "http://basedevmkp.vtexlocal.com.br:81/api/persistence/",
					json: {
						FilePath: fileName,
						Content: fileContent
						}
					}, (error, response, body) ->
						if response.statusCode is 200 then console.log 'file saved'
						else
				  	 		console.log "error: " + response.statusCode

	  changedFiles = Object.create(null)
	, 300)