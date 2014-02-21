request = require 'request'
prompt = require 'prompt'
Q = require 'q'

exports.getCredentials = ->
	deferred = Q.defer()
	schema = properties:
		login:
			required: true
		password:
			hidden: true

	prompt.start()
	prompt.get schema, (err, result) ->
		return deferred.reject(result) unless result.login and result.password
		return deferred.resolve(result)
	
	return deferred.promise

exports.getToken = (username, password) ->
	deferred = Q.defer()
	requestOptions = 
		uri: "https://vtexid.vtex.com.br/api/vtexid/pub/authentication/start"
	requestCallback = (error, response, body) ->
		if response.statusCode isnt 200
			return deferred.reject("Invalid status code #{response.statusCode}")
		try 
			token = JSON.parse(body).authenticationToken
			deferred.resolve(token)
		catch
			deferred.reject("Invalid JSON!")

	request requestOptions, requestCallback

	return deferred.promise

exports.authenticateUser = (login, password, token) ->
	deferred = Q.defer()

	requestOptions = 
		uri: "https://vtexid.vtex.com.br/api/vtexid/pub/authentication/classic/validate?authenticationToken=#{encodeURIComponent(token)}&login=#{encodeURIComponent(login)}&password=#{encodeURIComponent(password)}"

	requestCallback = (error, response, body) ->
		throw error if error
		if response.statusCode isnt 200
			console.log JSON.parse(body).error
			deferred.reject("Invalid status code #{response.statusCode}")
		try
			deferred.resolve(JSON.parse(body))
		catch
			deferred.reject("Invalid JSON!")

	request requestOptions, requestCallback

	return deferred.promise