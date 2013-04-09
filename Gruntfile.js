'use strict';
var path = require('path');
var cheerio = require('cheerio');
var chai = require('chai');
var lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;

var folderMount = function folderMount(connect, point) {
	return connect.static(path.resolve(point));
};


module.exports = function (grunt) {

	// Replaces paths for tags with 'data-min' attr
	// Filters out tags with 'data-ignore' attr
	grunt.file.readMin = function (path) {
		var file =  grunt.file.read(path);
		var $ = cheerio.load(file);
		var includeLabel = function(path, label) {
			return path.substring(0, path.lastIndexOf('.')) + label + path.substring(path.lastIndexOf('.'));
		};
		$('link,script').each(function(i, node){
			var minLabel = $(node).attr('data-min');
			var path = '';
			if (minLabel) {
				if (node.name == 'link') {
					path = $(node).attr('href');
					$(node).attr('href', includeLabel(path, minLabel));
				}
				else if (node.name == 'script') {
					path = $(node).attr('src');
					$(node).attr('src', includeLabel(path, minLabel));
				}
			}
			if ($(node).attr('data-ignore') != undefined) {
				$(node).remove();
			}
		});
		return $.html().replace(/\n{2,}/, '\n');
	};

	// Project configuration.
	grunt.initConfig({
		clean: ["build"],
		copy: {
			main: {
				files: [
					{expand: true, cwd: 'src/', src: ['**', '!includes/**' ,'!coffee/**', '!**/*.less'], dest: 'build/'}
				]
			}
		},
		coffee: {
			main: {
				expand: true,
				cwd: 'src/coffee',
				src: ['**/*.coffee'],
				dest: 'build/js/',
				ext: '.js'
			},
			test: {
				expand: true,
				cwd: 'test/coffee',
				src: ['**/*.coffee'],
				dest: 'build/test/js/',
				ext: '.js'
			}
		},
		less: {
			main: {
				files: {
					"build/style/main.css": "src/style/main.less"
				}
			}
		},
		uglify: {
			options: {
				mangle: true
			},
			main: {
				files: {
					'build/js/main.min.js': [
						'build/js/main.js'
					]
				}
			}
		},
		cssmin: {
			main: {
				files: {
					'build/style/main.min.css': [
						'build/style/main.css'
					]
				}
			}
		},
		replace: {
			prod: {
				options: {
					variables: {
						'includecss': '<%= grunt.file.readMin("src/includes/include-css.html") %>',
						'includejs': '<%= grunt.file.readMin("src/includes/include-js.html") %>'
					}
				},
				files: [
					{src: ['build/index.html'], dest: 'build/index.html'}
				]
			},
			dev: {
				options: {
					variables: {
						'includecss': '<%= grunt.file.read("src/includes/include-css.html") %>',
						'includejs': '<%= grunt.file.read("src/includes/include-js.html") %>'
					}
				},
				files: [
					{src: ['build/index.html'], dest: 'build/index.html'}
				]
			},
			debug: {
				options: {
					variables: '<%= replace.dev.options.variables %>'
				},
				files: [
					{src: ['build/index.html'], dest: 'build/index.debug.html'}
				]
			}
		},
		connect: {
			livereload: {
				options: {
					port: 9001,
					middleware: function (connect, options) {
						return [lrSnippet, folderMount(connect, 'build/')];
					}
				}
			}
		},
		regarde: {
			dev: {
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less'],
				tasks: ['dev', 'livereload']
			},
			prod: {
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less'],
				tasks: ['prod', 'livereload']
			},
			test: {
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less', 'test/**/*.coffee'],
				tasks: ['test'],
				spawn: true
			},
		},
		simplemocha: {
			options: {
				timeout: 3000,
				ignoreLeaks: false,
				ui: 'bdd',
				reporter: 'spec'
			},
			all: {
				src: 'build/test/js/**/*.js'
			}
		}
	});

	grunt.loadNpmTasks('grunt-contrib-connect');
	grunt.loadNpmTasks('grunt-contrib-livereload');
	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-less');
	grunt.loadNpmTasks('grunt-contrib-uglify');
	grunt.loadNpmTasks('grunt-contrib-cssmin');
	grunt.loadNpmTasks('grunt-regarde');
	grunt.loadNpmTasks('grunt-replace');
	grunt.loadNpmTasks('grunt-simple-mocha');

	/**
	 * Remote tasks
	 */
	grunt.registerTask(
			'remote',
			'Run Remote proxy server',
			function () {
				require('coffee-script');
				require('remote')();
			}
	);

	grunt.registerTask('prod', ['clean', 'copy', 'coffee', 'less', 'uglify', 'cssmin', 'replace:debug', 'replace:prod']);
	grunt.registerTask('dev', ['clean', 'copy', 'coffee', 'less', 'replace:dev']);
	grunt.registerTask('devmin', ['prod', 'livereload-start', 'connect', 'regarde:prod']);
	grunt.registerTask('default', ['dev', 'livereload-start', 'connect', 'regarde:dev']);
	grunt.registerTask('test', ['dev', 'simplemocha']);
	grunt.registerTask('devtest', ['test', 'regarde:test']);
};
