module.exports = (config) ->
	config.set
		files: [
			'build/js/people.js',
			'spec/**/*.coffee'
		]
		frameworks: ['jasmine']
		browsers: ['PhantomJS']
		preprocessors:
			"**/*.coffee": "coffee"