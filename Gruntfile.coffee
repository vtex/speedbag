path = require("path")
cheerio = require("cheerio")
chai = require("chai")
lrSnippet = require("grunt-contrib-livereload/lib/utils").livereloadSnippet
folderMount = (connect, point) -> connect.static path.resolve(point)

module.exports = (grunt) ->
	# Project configuration.
	grunt.initConfig
		clean: ["build"]
		copy:
			main:
				expand: true
				cwd: "src/"
				src: ["**", "!includes/**", "!coffee/**", "!**/*.less"]
				dest: "build/"

		coffee:
			main:
				expand: true
				cwd: "src/coffee"
				src: ["**/*.coffee"]
				dest: "build/js/"
				ext: ".js"

			test:
				expand: true
				cwd: "test/coffee"
				src: ["**/*.coffee"]
				dest: "build/test/js/"
				ext: ".js"

		less:
			main:
				files:
					"build/style/main.css": "src/style/main.less"

		useminPrepare:
			html: "build/index.html"

		usemin:
			html: "build/index.html"

		connect:
			livereload:
				options:
					port: 9001
					middleware: (connect, options) ->
						[lrSnippet, folderMount(connect, "build/")]

		regarde:
			dev:
				files: ["src/**/*.html", "src/**/*.coffee", "src/**/*.js", "src/**/*.less"]
				tasks: ["dev", "livereload"]

			prod:
				files: ["src/**/*.html", "src/**/*.coffee", "src/**/*.js", "src/**/*.less"]
				tasks: ["prod", "livereload"]

			test:
				files: ["src/**/*.html", "src/**/*.coffee", "src/**/*.js", "src/**/*.less", "test/**/*.coffee"]
				tasks: ["test"]
				spawn: true

		simplemocha:
			options:
				timeout: 3000
				ignoreLeaks: false
				ui: "bdd"
				reporter: "spec"

			all:
				src: "build/test/js/**/*.js"

	grunt.loadNpmTasks "grunt-contrib-connect"
	grunt.loadNpmTasks "grunt-contrib-concat"
	grunt.loadNpmTasks "grunt-contrib-livereload"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-contrib-clean"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-less"
	grunt.loadNpmTasks "grunt-contrib-uglify"
	grunt.loadNpmTasks "grunt-contrib-cssmin"
	grunt.loadNpmTasks "grunt-regarde"
	grunt.loadNpmTasks "grunt-simple-mocha"
	grunt.loadNpmTasks "grunt-usemin"

	###
	Remote tasks
	###
	grunt.registerTask "remote", "Run Remote proxy server", ->
		require "coffee-script"
		require("remote")()

	grunt.registerTask "dev", ["clean", "copy", "coffee", "less"]
	grunt.registerTask "prod", ["dev", "useminPrepare", "concat", "uglify", "cssmin", "usemin"]
	grunt.registerTask "default", ["dev", "livereload-start", "connect", "regarde:dev"]
	grunt.registerTask "devmin", ["prod", "livereload-start", "connect", "regarde:prod"]
	grunt.registerTask "test", ["dev", "simplemocha"]
	grunt.registerTask "devtest", ["test", "regarde:test"]
	grunt.registerTask "deploy", ["prod"]