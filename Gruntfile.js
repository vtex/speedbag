'use strict';
var path = require('path');
var lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;

var folderMount = function folderMount(connect, point) {
	return connect.static(path.resolve(point));
};

module.exports = function (grunt) {
	// Project configuration.
	grunt.initConfig({
		clean: ["build"],
		copy: {
			main: {
				files: [
					{expand: true, cwd: 'src/', src: ['**', '!coffee/**'], dest: 'build/'}
				]
			}
		},
		coffee: {
			glob_to_multiple: {
				expand: true,
				cwd: 'src/coffee',
				src: ['*.coffee'],
				dest: 'build/js/',
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
						'includecss': '<%= grunt.file.read("src/includes/include-css.prod.html") %>',
						'includejs': '<%= grunt.file.read("src/includes/include-js.prod.html") %>'
					}
				},
				files: [
					{src: ['build/index.html'], dest: 'build/index.html'}
				]
			},
			dev: {
				options: {
					variables: {
						'includecss': '<%= grunt.file.read("src/includes/include-css.dev.html") %>',
						'includejs': '<%= grunt.file.read("src/includes/include-js.dev.html") %>'
					}
				},
				files: [
					{src: ['build/index.html'], dest: 'build/index.html'}
				]
			}
		},
		connect: {
			livereload: {
				options: {
					port: 9001,
					middleware: function (connect, options) {
						return [lrSnippet, folderMount(connect, 'build/')]
					}
				}
			}
		},
		regarde: {
			dev: {
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.less'],
				tasks: ['dev', 'livereload']
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

	grunt.registerTask('prod', ['clean', 'copy', 'coffee', 'less', 'uglify', 'cssmin', 'replace:prod']);
	grunt.registerTask('dev', ['clean', 'copy', 'coffee', 'less', 'replace:dev']);
	grunt.registerTask('default', ['dev', 'livereload-start', 'connect', 'regarde']);
};
