module.exports = (grunt) ->
	replacements =
		'SERVICE_ENDPOINT': 'http://service.com'
		'VTEX_IO_HOST': 'io.vtex.com.br'

	processContentHost = (host) ->
		(content, path, versionDirectory) ->
			return content unless path in ['index.html', 'index.debug.html']
			return content
				.replace(/src="(\.\.\/)?(?!http|\/|\/\/|\#|\&|\'\&)/ig, 'src="//' + host + '/' + versionDirectory)
				.replace(/href="(\.\.\/)?(?!http|\/|\/\/|\#|\&|\'\&|javascript\:void\(0\)\;)/ig, 'href="//' + host + '/' + versionDirectory)

	# Project configuration.
	grunt.initConfig
		relativePath: ''

		# Tasks
		clean: 
			main: ['build', 'build-raw']

		copy:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**', '!coffee/**', '!**/*.less']
					dest: 'build-raw/<%= relativePath %>'
				,
					src: ['src/index.html']
					dest: 'build-raw/<%= relativePath %>/index.debug.html'
				,
					expand: true
					cwd: 'spec/'
					src: ['**', '!**/*.coffee']
					dest: 'build-raw/<%= relativePath %>/spec/'
				]
			build:
				expand: true
				cwd: 'build-raw/'
				src: '*'
				dest: 'build/'

		coffee:
			main:
				files: [
					expand: true
					cwd: 'src/coffee'
					src: ['**/*.coffee']
					dest: 'build-raw/<%= relativePath %>/js/'
					ext: '.js'
				,
					expand: true
					cwd: 'spec/'
					src: ['**/*.coffee']
					dest: 'build-raw/<%= relativePath %>/spec/'
					ext: '.js'
				]

		less:
			main:
				files:
					'build-raw/<%= relativePath %>/style/main.css': 'src/style/main.less'

		useminPrepare:
			html: 'build-raw/<%= relativePath %>/index.html'

		usemin:
			html: 'build-raw/<%= relativePath %>/index.html'

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
					'build/<%= relativePath %>/index.html': ['build-raw/<%= relativePath %>/index.html']
					'build/<%= relativePath %>/index.debug.html': ['build-raw/<%= relativePath %>/index.debug.html']
				options:
					replacements: ({'pattern': new RegExp(key, "gi"), 'replacement': value} for key, value of replacements)

		connect:
			main:
				options:
					port: 9001
					base: 'build/'

		remote: main: {}

		watch:
			main:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less']
				tasks: ['build', 'karma:unit:run']

		concurrent:
			transform: ['copy:main', 'coffee', 'less']

		vtex_deploy:
			main:
				options:
					s3ConfigFile: '/home/guilherme/s3.json',
					indexPath: 'build/index.html',
					processContent: processContentHost("io.vtex.com.br")
					whoamiPath: 'whoami',
					dryRun: true
			walmart:
				options:
					buildDirectory: 'build-raw',
					s3ConfigFile: '/home/guilherme/s3.json',
					bucket: 'vtex-io-walmart',
					requireEnvironmentType: 'stable',
					processContent: processContentHost("VTEX_IO_HOST")
					dryRun: true

	grunt.loadNpmTasks name for name of grunt.file.readJSON('package.json').dependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['build', 'server', 'karma:unit', 'watch:main']
	grunt.registerTask 'build', ['clean', 'concurrent:transform', 'copy:build', 'string-replace']
	grunt.registerTask 'dist', ['build', 'useminPrepare', 'concat', 'uglify', 'cssmin', 'usemin'] # Dist - minifies files
	grunt.registerTask 'test', ['karma:single']
	grunt.registerTask 'server', ['connect', 'remote']