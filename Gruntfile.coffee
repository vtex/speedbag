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
					src: ['**', '!**/*.less', '!**/*.coffee']
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

		coffee:
      main:
	      files: [
          expand: true
          cwd: 'src/coffee'
          src: ['**/*.coffee']
          dest: 'build-raw/scripts/'
          ext: '.js'
	      ]

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

		connect:
			main:
				options:
					port: 9001
					base: 'build/'
					livereload: true

		remote: main: {}

		watch:
			dev:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.js', 'src/**/*.less', 'src/**/*.coffee', 'src/**/*.css']
				tasks: ['clean', 'concurrent:transform', 'copy:build']

		concurrent:
			transform: ['copy:main', 'coffee', 'less']

		
	grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['clean', 'concurrent:transform', 'copy:build', 'server', 'watch']
	grunt.registerTask 'min', ['useminPrepare', 'concat', 'uglify', 'cssmin', 'usemin'] # minifies files
	grunt.registerTask 'dist', ['clean', 'concurrent:transform', 'min', 'copy:build'] # Dist - minifies files
	grunt.registerTask 'server', ['connect', 'remote']
	grunt.registerTask 'distLocal', ['dist', 'server', 'watch']
