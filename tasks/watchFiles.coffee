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
		  	 	uri: "http://basedevmkp.vtexlocal.com.br",
		  	 	form: {
		  	 		filePath: file
		  	 	}
		  	 }
		  else
			  fileContent = cat file
			  console.log fileContent
			  request.put {
			  		uri: "http://basedevmkp.vtexlocal.com.br",
					body: fileContent
					form: {
						filePath: file
						}
					}, (error, response, body) ->
						if response.statusCode is 200
							console.log 'file saved'
						else
							console.log 'error: '+ response.statusCode
							console.log body

	  changedFiles = Object.create(null)
	, 300)