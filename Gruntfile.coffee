path = require('path')
fs = require('fs')

module.exports = (grunt) ->
	# Project configuration.
	grunt.initConfig
		environment: 'dev'
		resourceToken: process.env['RESOURCE_TOKEN'] or 'http://vtex.io'
		gitCommit: process.env['GIT_COMMIT'] or 'GIT_COMMIT'
		deployDirectory: path.normalize(process.env['DEPLOY_DIRECTORY'] ? 'deploy')
		relativePath: ''
		pkg: grunt.file.readJSON('package.json')
		pacha: grunt.file.readJSON('tools/pachamama/pachamama.config')[0]
		clean: ['build']
		copy:
			main:
				expand: true
				cwd: 'src/'
				src: ['**', '!includes/**', '!coffee/**', '!**/*.less']
				dest: 'build/<%= relativePath %>'

			debug:
				src: ['src/index.html']
				dest: 'build/<%= relativePath %>/index.debug.html'

			deploy:
				expand: true
				cwd: 'build/<%= relativePath %>/'
				src: ['**', '!includes/**', '!coffee/**', '!**/*.less']
				dest: '<%= deployDirectory %>/<%= gitCommit %>/'

			env:
				expand: true
				cwd: '<%= deployDirectory %>/<%= gitCommit %>/'
				src: ['index.html', 'index.debug.html']
				dest: '<%= deployDirectory %>/<%= environment %>/'

		coffee:
			main:
				expand: true
				cwd: 'src/coffee'
				src: ['**/*.coffee']
				dest: 'build/<%= relativePath %>/js/'
				ext: '.js'

			test:
				expand: true
				cwd: 'spec/'
				src: ['**/*.coffee']
				dest: 'build/<%= relativePath %>/spec/'
				ext: '.js'

		less:
			main:
				files:
					'build/<%= relativePath %>/style/main.css': 'src/style/main.less'

		useminPrepare:
			html: 'build/<%= relativePath %>/index.html'

		usemin:
			html: 'build/<%= relativePath %>/index.html'

		jasmine:
			test:
				src: ['build/<%= relativePath %>/lib/zepto/zepto.js', 'build/<%= relativePath %>/js/**/*.js']
				options:
					specs: 'build/<%= relativePath %>/spec/*Spec.js'

		'string-replace':
			deploy:
				files:
					'<%= deployDirectory %>/<%= environment %>/index.html': ['<%= deployDirectory %>/<%= environment %>/index.html']
					'<%= deployDirectory %>/<%= environment %>/index.debug.html': ['<%= deployDirectory %>/<%= environment %>/index.debug.html']

				options:
					replacements: [
						pattern: /src="(\.\.\/)?(?!http|\/|\/\/|\#)/ig
						replacement: 'src="<%= resourceToken %>/<%= pacha.infrastructure.s3.ApplicationDirectory %>/<%= gitCommit %>/'
					,
						pattern: /href="(\.\.\/)?(?!http|\/|\/\/|\#)/ig
						replacement: 'href="<%= resourceToken %>/<%= pacha.infrastructure.s3.ApplicationDirectory %>/<%= gitCommit %>/'
					,
						pattern: '<script src="http://localhost:35729/livereload.js"></script>'
						replacement: ''
					]

		connect:
			dev:
				options:
					port: 9001
					base: 'build/'

		watch:
			options:
				livereload: true

			dev:
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less']
				tasks: ['dev']

			prod:
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less']
				tasks: ['prod']

			test:
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less', 'spec/**/*.coffee']
				tasks: ['test']
				spawn: true

	grunt.loadNpmTasks 'grunt-contrib-connect'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-jasmine'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-usemin'
	grunt.loadNpmTasks 'grunt-string-replace'

	grunt.registerTask 'default', ['dev-watch']

	# Dev
	grunt.registerTask 'dev', ['clean', 'copy:main', 'coffee', 'less']
	grunt.registerTask 'dev-watch', ['dev', 'connect', 'watch:dev']

	# Prod - minifies files
	grunt.registerTask 'prod', ['dev', 'copy:debug', 'useminPrepare', 'concat', 'uglify', 'cssmin', 'usemin']
	grunt.registerTask 'prod-watch', ['prod', 'connect', 'watch:prod']

	# Test
	grunt.registerTask 'test', ['dev', 'jasmine']
	grunt.registerTask 'test-watch', ['test', 'watch:test']

	# Generates version folder
	grunt.registerTask 'gen-version', ->
		env = this.args[0] or 'dev'
		grunt.config 'environment', env
		grunt.log.writeln 'Deploying to environment: '.cyan + env.green
		grunt.log.writeln 'VTEX IO Directory: '.cyan + grunt.config('pacha').infrastructure.s3.ApplicationDirectory.green
		grunt.log.writeln 'Version set by environment variable GIT_COMMIT to: '.cyan + grunt.config('gitCommit').green
		grunt.log.writeln 'Rersource token set by environment variable RESOURCE_TOKEN to: '.cyan + grunt.config('resourceToken').green
		grunt.log.writeln 'Deploy folder: '.cyan + grunt.config('deployDirectory').green
		grunt.task.run ['copy:env', 'string-replace:deploy']

	# Deploy - creates deploy folder structure
	grunt.registerTask 'deploy', ->
		env = this.args[0] or 'dev'
		commit = grunt.config('gitCommit')
		deployDir = path.resolve grunt.config('deployDirectory'), commit
		deployExists = false
		grunt.log.writeln 'Version deploy dir set to: '.cyan + deployDir.green
		try
			deployExists = fs.existsSync deployDir
		catch e
			grunt.log.writeln 'Error reading deploy folder'.red
			console.log e

		if deployExists
			grunt.log.writeln 'Folder '.cyan + deployDir.green + ' already exists.'.cyan
			grunt.log.writeln 'Skipping build process and generating environment folder.'.cyan
			grunt.task.run ['clean', 'gen-version:' + env]
		else
			grunt.task.run ['prod', 'copy:deploy', 'gen-version:' + env]

	# Example usage of deploy task
	grunt.registerTask 'deploy-example', ['deploy:master']

	#	Remote task
	grunt.registerTask 'remote', 'Run Remote proxy server', ->
		require 'coffee-script'
		require('remote')()