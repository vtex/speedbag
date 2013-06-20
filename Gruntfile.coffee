path = require('path')
fs = require('fs')

module.exports = (grunt) ->
	pacha = grunt.file.readJSON('tools/pachamama/pachamama.config')[0]
	whoami = grunt.file.readJSON('meta/whoami')
	# Project configuration.
	grunt.initConfig
		relativePath: ''
		applicationRoot: process.env['APPLICATION_ROOT'] or whoami.roots[0]
		deployDirectory: path.normalize(process.env['DEPLOY_DIRECTORY'] ? 'deploy')
		gitCommit: process.env['GIT_COMMIT'] or 'GIT_COMMIT'

		# Version variables
		acronym: pacha.acronym
		environmentName: process.env['ENVIRONMENT_NAME'] or '01-00-00'
		buildNumber: process.env['BUILD_NUMBER'] or '1'
		environmentType: process.env['ENVIRONMENT_TYPE'] or 'stable'
		versionName: -> [grunt.config('acronym'), grunt.config('environmentName'), grunt.config('buildNumber'),
										 grunt.config('environmentType')].join('-')

		# Tasks
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

			commit:
				expand: true
				cwd: 'build/<%= relativePath %>/'
				src: ['**', '!includes/**', '!coffee/**', '!**/*.less']
				dest: '<%= deployDirectory %>/<%= gitCommit %>/'

			version:
				expand: true
				cwd: '<%= deployDirectory %>/<%= gitCommit %>/'
				src: ['**']
				dest: '<%= deployDirectory %>/<%= versionName() %>/'

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

		karma:
			options:
				configFile: 'karma.conf.js'
			unit:
				background: true
			deploy:
				singleRun: true

		'string-replace':
			deploy:
				files:
					'<%= deployDirectory %>/<%= versionName() %>/index.html': ['<%= deployDirectory %>/<%= versionName() %>/index.html']
					'<%= deployDirectory %>/<%= versionName() %>/index.debug.html': ['<%= deployDirectory %>/<%= versionName() %>/index.debug.html']

				options:
					replacements: [
						pattern: /src="(\.\.\/)?(?!http|\/|\/\/|\#)/ig
						replacement: 'src="<%= applicationRoot %>/'
					,
						pattern: /href="(\.\.\/)?(?!http|\/|\/\/|\#)/ig
						replacement: 'href="<%= applicationRoot %>/'
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
				tasks: ['dev', 'karma:unit:run']

	grunt.loadNpmTasks 'grunt-contrib-connect'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-usemin'
	grunt.loadNpmTasks 'grunt-string-replace'
	grunt.loadNpmTasks 'grunt-karma'

	grunt.registerTask 'default', ['dev-watch']

	# Dev
	grunt.registerTask 'dev', ['clean', 'copy:main', 'coffee', 'less']
	grunt.registerTask 'dev-watch', ['dev', 'connect', 'remote', 'watch:dev']

	# Prod - minifies files
	grunt.registerTask 'prod', ['dev', 'copy:debug', 'useminPrepare', 'concat', 'uglify', 'cssmin', 'usemin']
	grunt.registerTask 'prod-watch', ['prod', 'connect', 'remote', 'watch:prod']

	# Test
	grunt.registerTask 'test', ['dev', 'karma:deploy']
	grunt.registerTask 'test-watch', ['dev', 'karma:unit', 'watch:test']
	
	# TDD
	grunt.registerTask 'tdd', ['dev', 'connect', 'karma:unit', 'remote', 'watch:test']

	# Tasks for deploy build
	grunt.registerTask 'gen-commit', ['clean', 'copy:main', 'coffee', 'less', 'copy:debug',
																		'useminPrepare', 'concat', 'uglify', 'cssmin', 'usemin']

	# Generates version folder
	grunt.registerTask 'gen-version', ->
		grunt.log.writeln 'Application root: '.cyan + grunt.config('applicationRoot').green
		grunt.log.writeln 'Deploying to environmentName: '.cyan + grunt.config('environmentName').green
		grunt.log.writeln 'Deploying to buildNumber: '.cyan + grunt.config('buildNumber').green
		grunt.log.writeln 'Deploying to environmentType: '.cyan + grunt.config('environmentType').green
		grunt.log.writeln 'Version name: '.cyan + grunt.config('versionName')().green
		grunt.log.writeln 'Version deploy directory: '.cyan + (path.resolve grunt.config('deployDirectory'), grunt.config('versionName')()).green
		grunt.task.run ['copy:version', 'string-replace:deploy']

	# Deploy - creates deploy folder structure
	grunt.registerTask 'deploy', ->
		commit = grunt.config('gitCommit')
		deployDir = path.resolve grunt.config('deployDirectory'), commit
		deployExists = false
		grunt.log.writeln 'Commit: '.cyan + grunt.config('gitCommit').green
		grunt.log.writeln 'Commit deploy directory: '.cyan + deployDir.green
		try
			deployExists = fs.existsSync deployDir
		catch e
			grunt.log.writeln 'Error reading deploy folder'.red
			console.log e

		if deployExists
			grunt.log.writeln 'Folder '.cyan + deployDir.green + ' already exists.'.cyan
			grunt.log.writeln 'Skipping build process and generating version folder.'.cyan
			grunt.task.run ['clean', 'gen-version']
		else
			grunt.task.run ['gen-commit', 'karma:deploy', 'copy:commit', 'gen-version']

	#	Remote task
	grunt.registerTask 'remote', 'Run Remote proxy server', ->
		require 'coffee-script'
		require('remote')()