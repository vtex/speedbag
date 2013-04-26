path = require('path')
exec = require('child_process').exec
lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet
folderMount = (connect, point) -> connect.static path.resolve(point)

module.exports = (grunt) ->
	# Project configuration.
	grunt.initConfig
		resourceToken: process.env['RESOURCE_TOKEN'] or 'http://vtex.io'
		relativePath: ''
		pkg: grunt.file.readJSON('package.json')
		clean: ['build', 'deploy']
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
				dest: 'deploy/<%= meta.commit %>/'

			env:
				expand: true
				cwd: 'build/<%= relativePath %>'
				src: ['index.html', 'index.debug.html']
				dest: 'deploy/<%= meta.env %>/'

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
					'deploy/<%= meta.env %>/index.html': ['deploy/<%= meta.env %>/index.html']
					'deploy/<%= meta.env %>/index.debug.html': ['deploy/<%= meta.env %>/index.debug.html']

				options:
					replacements: [
						pattern: /src="(\.\.\/)?(?!http|\/|\/\/)/ig
						replacement: 'src="<%= resourceToken %>/<%= pkg.name %>/<%= meta.commit %>/'
					,
						pattern: /href="(\.\.\/)?(?!http|\/|\/\/)/ig
						replacement: 'href="<%= resourceToken %>/<%= pkg.name %>/<%= meta.commit %>/'
					]

		connect:
			livereload:
				options:
					port: 9001
					middleware: (connect, options) ->
						[lrSnippet, folderMount(connect, 'build/')]

		regarde:
			dev:
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less']
				tasks: ['dev', 'livereload']

			prod:
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less']
				tasks: ['prod', 'livereload']

			test:
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less', 'spec/**/*.coffee']
				tasks: ['test']
				spawn: true

	# Looks for the commit hash in a GIT_COMMIT env var, or tries calling git.
	grunt.registerTask 'set-version', ->
		if process.env.GIT_COMMIT
			grunt.config 'meta.commit', new String(process.env.GIT_COMMIT)
			grunt.log.writeln 'Version set by environment variable GIT_COMMIT to: ' + grunt.config('meta.commit')
		else
			done = @async()
			exec 'git rev-parse --verify HEAD', (err, stdout, stderr) ->
				if err
					grunt.log.writeln 'Failed to set version by git.'
					done()
					return
				grunt.config 'meta.commit', stdout.replace('\n', '')
				grunt.log.writeln 'Version set by git commit to: ' + grunt.config('meta.commit')
				done()

	grunt.loadNpmTasks 'grunt-contrib-connect'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-livereload'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-jasmine'
	grunt.loadNpmTasks 'grunt-regarde'
	grunt.loadNpmTasks 'grunt-usemin'
	grunt.loadNpmTasks 'grunt-string-replace'

	grunt.registerTask 'default', ['dev-watch']

	# Dev
	grunt.registerTask 'dev', ['clean', 'copy:main', 'coffee', 'less']
	grunt.registerTask 'dev-watch', ['dev', 'livereload-start', 'connect', 'regarde:dev']

	# Prod - minifies files
	grunt.registerTask 'prod', ['dev', 'copy:debug', 'useminPrepare', 'concat', 'uglify', 'cssmin', 'usemin']
	grunt.registerTask 'prod-watch', ['prod', 'livereload-start', 'connect', 'regarde:prod']

	# Test
	grunt.registerTask 'test', ['dev', 'jasmine']
	grunt.registerTask 'test-watch', ['test', 'regarde:test']

	# Generates version folder
	grunt.registerTask 'gen-version', ->
		env = this.args[0] or 'dev'
		console.log 'Deploying to environment:', env
		grunt.config 'meta.env', env
		grunt.task.run ['set-version', 'copy:env', 'string-replace:deploy']
	
	# Deploy - creates deploy folder structure
	grunt.registerTask 'deploy', ->
		env = this.args[0] or 'dev'
		grunt.task.run ['prod', 'jasmine', 'gen-version:' + env, 'copy:deploy']
		
	# Example usage of deploy task
	grunt.registerTask 'deploy-example', ['deploy:master']

	#	Remote task
	grunt.registerTask 'remote', 'Run Remote proxy server', ->
		require 'coffee-script'
		require('remote')()
