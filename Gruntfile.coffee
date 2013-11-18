module.exports = (grunt) ->
	pkg = grunt.file.readJSON('package.json')

	# Project configuration.
	grunt.initConfig

		# Tasks
		clean: 
			main: ['build', 'build-raw', '.tmp']

		copy:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**', '!**/*.less']
					dest: 'build-raw/'
				,
					src: ['src/index.html']
					dest: 'build-raw/index.debug.html'
				]
			build:
				expand: true
				cwd: 'build-raw/'
				src: '**/*.*'
				dest: 'build/'

		less:
			main:
				files:
					'build-raw/style/main.css': 'src/style/main.less'

		useminPrepare:
			html: 'build-raw/index.html'
			options:
        dest: 'build-raw/'

		usemin:
			html: 'build-raw/index.html'

		'string-replace':
			dist:
				files:
					'build-raw/index.html': ['build-raw/index.html']
				options:
					replacements: [
						pattern: '<script src="http://localhost:35729/livereload.js"></script>'
						replacement: ''
					]

		connect:
			main:
				options:
					port: 9001
					base: 'build/'

		remote: main: {}

		watch:
			dev:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.js', 'src/**/*.less', 'src/**/*.css']
				tasks: ['clean', 'concurrent:transform', 'copy:build']

		concurrent:
			transform: ['copy:main', 'less']

		
	grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['clean', 'concurrent:transform', 'copy:build', 'server', 'watch']
	grunt.registerTask 'min', ['useminPrepare', 'concat', 'uglify', 'cssmin', 'usemin'] # minifies files
	grunt.registerTask 'dist', ['clean', 'concurrent:transform', 'min', 'string-replace:dist', 'copy:build'] # Dist - minifies files
	grunt.registerTask 'server', ['connect', 'remote']
	grunt.registerTask 'distLocal', ['dist', 'server', 'watch']
