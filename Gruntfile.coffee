GruntVTEX = require 'grunt-vtex'

module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'

  replaceMap = {}
  replaceMap["/speedbag/"] = "//io.vtex.com.br/#{pkg.name}/#{pkg.version}/"
  replaceMap["\<\!\-\-remove\-\-\>(.|\n)*\<\!\-\-endremove\-\-\>"] = ""

  defaultConfig = GruntVTEX.generateConfig grunt, pkg,
    followHttps: true
    replaceMap: replaceMap
    livereload: !grunt.option('no-lr')
    relativePath: "speedbag"

  # Add custom configuration here as needed
  customConfig =
    karma:
      options:
        configFile: 'karma.conf.coffee'
      ci:
        singleRun: true
      dev:
        singleRun: false

  tasks =
    # Building block tasks
    build: ['clean', 'jshint', 'concat:templates', 'copy:main', 'copy:pkg', 'copy:janus_index', 'nginclude', 'coffeelint', 'coffee', 'recess', 'less', 'ngtemplates']
    min: ['useminPrepare', 'concat', 'uglify', 'cssmin', 'usemin'] # minifies files
    # Deploy tasks
    dist: ['build', 'min', 'copy:deploy'] # Dist - minifies files
    test: ['karma:ci']
    devtest: ['karma:dev']
    vtex_deploy: ['shell:cp']
    # Development tasks
    default: ['build', 'connect', 'watch']
    devmin: ['build', 'min', 'connect:http:keepalive'] # Minifies files and serve

  # Project configuration.
  grunt.config.init defaultConfig
  grunt.config.merge customConfig
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-' and name isnt 'grunt-vtex'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks
