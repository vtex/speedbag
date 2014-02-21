require 'shelljs/global'
auth = require './lib/auth'
request = require 'request'
util = require './lib/util'
watch = require 'watch'
load = require 'lodash'
Q = require 'q'

module.exports = (grunt) ->
	changedFiles = {}

	onChange = (changedFiles) ->
		deferred = Q.defer()
		requestMessage = createRequestMessage changedFiles

		requestOptions = 
			uri: "http://basedevmkp.vtexlocal.com.br:81/api/persistence/"
			json: requestMessage
			headers:
				'user-key': 'XXX'

		requestCallBack = (error, response, body) ->
			if response.statusCode isnt 200
				return deferred.reject("Invalid status code #{response.statusCode}")
			try
				console.log "ASS"
				cleanChangedFiles()
				deferred.resolve()
			catch e
				deferred.reject()

		request.put requestOptions, requestCallBack

		return deferred.promise

	syncFilesToS3 = (root) ->
		for file in grunt.file.expand root
			if grunt.file.isFile file
				console.log "sync " + file
				changedFiles[file] = 'created'
				onChange(changedFiles)

	watchFiles = ->
		watch.createMonitor 'src', (monitor) ->
			monitor.on 'created', (filePath) ->
				console.log "created " + filePath
				addCreateFile(filePath)
				onChange changedFiles

			monitor.on 'removed', (filePath) ->
				console.log "removed " + filePath
				changedFiles[filePath] = 'removed'
				onChange changedFiles

			monitor.on 'changed', (filePath) ->
				console.log "changed " + filePath
				changedFiles[filePath] = 'changed'
				onChange changedFiles

	addCreateFile = (filePath) ->
		if grunt.file.isFile filePath
			changedFiles[filePath] = 'created'
		if grunt.file.isDir filePath
			grunt.file.recurse filePath, (abspath) ->
				if grunt.file.isFile abspath
					changedFiles[abspath] = 'created'

	createRequestMessage = (changedFiles) ->	
		messages = []
		for path in Object.keys changedFiles
			messages.push util.createJsonMessage path, changedFiles
		return messages

	cleanChangedFiles = ->
		changedFiles = Object.create null

	athentication = ->
		deferred = Q.defer()
		credentialsPromise = auth.getCredentials()
		tokenPromise = auth.getToken()

		authPromise = Q.all([credentialsPromise, tokenPromise]).spread (credentials, token) ->
			auth.authenticateUser(credentials.login, credentials.password, token)

		authPromise.then (success) ->
			return deferred.resolve(success)
			
		authPromise.fail (reason) ->
			return deferred.reject(reason)
		
		return deferred.promise

	grunt.registerTask 'syncfiles', ->
		done = this.async()
		grunt.config.requires 'sync.root'

		root = grunt.config 'sync.root'
		changedFiles["src/"] = 'removed'

		authPromise = athentication()

		authPromise.then( -> onChange(changedFiles))
		.then  (onChangeReturn) ->
			done()

		.fail (reason) ->
			done(new Error("Something went wrong. " + reason)) if reason isnt 'Success'

	grunt.registerTask 'workspace', ->
		done = this.async()
		credentials = util.getCredentials()
		
		done(new Error("Authentication failed. Call \'grunt login\'")) if credentials is null

		requestOptions =
			url: "http://basedevmkp.vtexlocal.com.br:81/api/workspace/"

		requestCallBack = (error, response, body) ->
			if response.statusCode isnt 200 then done(false)

			json = JSON.parse body
			for file in json
				contents = util.getFileContentAscii file.content
				grunt.file.write(file.path, contents)
			done()

		request requestOptions, requestCallBack

	grunt.registerTask 'login', ->
		done = this.async()
		authPromise = athentication()
		
		authPromise.then (response) ->
			msg = "Authentication: \'#{response.authStatus}\'"
			try
				return done(new Error(msg)) if response.authStatus isnt 'Success'

				json = JSON.stringify response, null, 4
				grunt.file.write "tasks/auth.json", json
				done(grunt.log.oklns(msg))
			catch
				return done(new Error(msg))

		.fail (reason) ->
			done(new Error("Something went wrong. " + reason.authStatus)) if reason isnt 'Success'