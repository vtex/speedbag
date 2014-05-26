GruntVTEX = require 'grunt-vtex'

module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'
  
  config = GruntVTEX.generateConfig grunt, pkg

  tasks =
    # Building block tasks
    build: ['clean', 'concat:templates', 'copy:main', 'copy:pkg', 'copy:janus_index', 'nginclude', 'coffee', 'less', 'ngtemplates']
    min: ['useminPrepare', 'concat', 'uglify', 'usemin'] # minifies files
    # Deploy tasks
    dist: ['build', 'min', 'copy:deploy'] # Dist - minifies files
    test: []
    vtex_deploy: ['shell:cp']
    # Development tasks
    default: ['build', 'connect', 'watch']
    devmin: ['build', 'min', 'connect:http:keepalive'] # Minifies files and serve

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-' and name isnt 'grunt-vtex'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks
