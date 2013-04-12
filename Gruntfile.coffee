path = require("path")
exec = require('child_process').exec
cheerio = require("cheerio")
chai = require("chai")
lrSnippet = require("grunt-contrib-livereload/lib/utils").livereloadSnippet
folderMount = (connect, point) -> connect.static path.resolve(point)

module.exports = (grunt) ->
	# Project configuration.
	grunt.initConfig
		resourceToken: '$resourcesUrl$'
		pkg: grunt.file.readJSON('package.json')
		clean: ["build", "deploy"]
		copy:
			main:
				expand: true
				cwd: "src/"
				src: ["**", "!includes/**", "!coffee/**", "!**/*.less"]
				dest: "build/"

			debug:
				src: ["src/index.html"]
				dest: "build/index.debug.html"

			deploy:
				expand: true
				cwd: "build/"
				src: ["**", "!includes/**", "!coffee/**", "!**/*.less"]
				dest: "deploy/<%= meta.commit %>/"

			env:
				expand: true
				cwd: "deploy/<%= meta.commit %>/"
				src: ["index.html", "index.debug.html"]
				dest: "deploy/<%= meta.env %>/"

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

		'string-replace':
			deploy:
				files:
					"deploy/<%= meta.env %>/index.html": ["deploy/<%= meta.env %>/index.html"]
					"deploy/<%= meta.env %>/index.debug.html": ["deploy/<%= meta.env %>/index.debug.html"]

				options:
					replacements: [
						pattern: /src="/ig
						replacement: 'src="<%= resourceToken %>/<%= pkg.name %>/<%= meta.commit %>/'
					,
						pattern: /href="/ig
						replacement: 'href="<%= resourceToken %>/<%= pkg.name %>/<%= meta.commit %>/'
					]

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

	grunt.registerTask "env", ->
		env = this.args[0]
		console.log "Setting env to:", env
		grunt.config "meta.env", env

	grunt.registerTask "deploy-version", ->
		if process.env.GIT_COMMIT
			grunt.config "meta.commit", new String(process.env.GIT_COMMIT)
			grunt.log.writeln "Version set by environment variable GIT_COMMIT to: " + grunt.config("meta.commit")
		else
			done = @async()
			exec "git rev-parse --verify HEAD", (err, stdout, stderr) ->
				if err
					grunt.log.writeln "Failed to set version by git."
					done()
					return
				grunt.config "meta.commit", stdout.replace("\n", "")
				grunt.log.writeln "Version set by git commit to: " + grunt.config("meta.commit")
				done()

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
	grunt.loadNpmTasks "grunt-string-replace"

	###
	Remote tasks
	###
	grunt.registerTask "remote", "Run Remote proxy server", ->
		require "coffee-script"
		require("remote")()

	grunt.registerTask "dev", ["clean", "copy:main", "coffee", "less"]
	grunt.registerTask "prod", ["dev", "copy:debug", "useminPrepare", "concat", "uglify", "cssmin", "usemin"]
	grunt.registerTask "default", ["dev", "livereload-start", "connect", "regarde:dev"]
	grunt.registerTask "devmin", ["prod", "livereload-start", "connect", "regarde:prod"]
	grunt.registerTask "test", ["dev", "simplemocha"]
	grunt.registerTask "devtest", ["test", "regarde:test"]
	# Ran after env task
	grunt.registerTask "deploy", ["prod", "deploy-version", "copy:deploy", "copy:env", "string-replace:deploy"]

	# Example usage of env task
	grunt.registerTask "deploy-master", ["env:master", "deploy"]