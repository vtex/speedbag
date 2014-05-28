module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'

  config = 
    connect:
      http:
        options:
          open: 'http://localhost:80'
          hostname: "*"
          port: 80
          base: '.'
          
    watch:
      options:
        livereload: true
      main:
        files: ['index.html']

  tasks =
    # Development tasks
    default: ['connect', 'watch']

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-' and name isnt 'grunt-vtex'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks
