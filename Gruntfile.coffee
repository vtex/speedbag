module.exports = (grunt) ->
	replacements =
		'SERVICE_ENDPOINT': process.env['SERVICE_ENDPOINT'] or 'http://service.com'
		'APPLICATION_ROOT': process.env['APPLICATION_ROOT'] or 'admin/speedbag'

	# Project configuration.
	grunt.initConfig
		relativePath: ''

		# Tasks
		clean: 
			main: ['build']

		copy:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**', '!coffee/**', '!**/*.less']
					dest: 'build/<%= relativePath %>'
				,
					src: ['src/index.html']
					dest: 'build/<%= relativePath %>/index.debug.html'
				,
					expand: true
					cwd: 'spec/'
					src: ['**', '!**/*.coffee']
					dest: 'build/<%= relativePath %>/spec/'
				]

		coffee:
			main:
				files: [
					expand: true
					cwd: 'src/coffee'
					src: ['**/*.coffee']
					dest: 'build/<%= relativePath %>/js/'
					ext: '.js'
				,
					expand: true
					cwd: 'spec/'
					src: ['**/*.coffee']
					dest: 'build/<%= relativePath %>/spec/'
					ext: '.js'
				]

		less:
			main:
				files:
					'build/<%= relativePath %>/style/main.css': 'src/style/main.less'

		useminPrepare:
			html: 'build/<%= relativePath %>/index.html'

		usemin:
			html: 'build/<%= relativePath %>/index.html'

		### example - we actually use grunt-usemin to min. check index.html for the build tags
  	uglify:
			dist:
				files:
					'dist/people.min.js': ['dist/people.js']
  	###

		karma:
			options:
				configFile: 'karma.conf.js'
			unit:
				background: true
			single:
				singleRun: true

		'string-replace':
			main:
				files:
					'build/<%= relativePath %>/index.html': ['build/<%= relativePath %>/index.html']
				options:
					replacements: ({'pattern': new RegExp(key, "gi"), 'replacement': value} for key, value of replacements)

		connect:
			main:
				options:
					port: 9001
					base: 'build/'

		watch:
			main:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less']
				tasks: ['build', 'karma:unit:run']

	grunt.loadNpmTasks name for name of grunt.file.readJSON('package.json').dependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['build', 'server', 'karma:unit', 'watch:main']
	grunt.registerTask 'build', ['clean', 'copy:main', 'coffee', 'less', 'string-replace']
	grunt.registerTask 'dist', ['build', 'useminPrepare', 'concat', 'uglify', 'cssmin', 'usemin'] 	# Dist - minifies files
	grunt.registerTask 'test', ['karma:single']
	grunt.registerTask 'server', ['connect', 'remote']
	grunt.registerTask 'remote', 'Run Remote proxy server', -> require('coffee-script') and require('remote')()