module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')

  # Project configuration.
  grunt.initConfig
    relativePath: pkg.paths[0].slice(1) # Removes first slash

  # Tasks
    clean:
      main: ['build', 'tmp-deploy']

    copy:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**', '!coffee/**', '!style/**', '!views/**']
          dest: 'build/<%= relativePath %>/'
        ,
          src: ['package.json']
          dest: 'build/<%= relativePath %>/package.json'
        ,
          # Serve index.html where janus expects it
          src: ['src/index.html']
          dest: 'build/<%= relativePath %>/<%= relativePath %>/index.html'
        ]

    coffee:
      main:
        files: [
          expand: true
          cwd: 'src/coffee'
          src: ['**/*.coffee']
          dest: 'build/<%= relativePath %>/js/'
          ext: '.js'
        ]

    less:
      main:
        files: [
          expand: true
          cwd: 'src/style'
          src: ['main.less', 'print.less']
          dest: 'build/<%= relativePath %>/style/'
          ext: '.css'
        ]

    uglify:
      options:
        mangle: false

    ngtemplates:
      main:
        cwd: 'src/'
        src: 'views/**/*.html',
        dest: 'build/<%= relativePath %>/js/templates.js'
        options:
          module: 'app'
          htmlmin:  collapseWhitespace: true, collapseBooleanAttributes: true

    useminPrepare:
      html: 'build/<%= relativePath %>/index.html'
      options:
        dest: 'build/'
        root: 'build/'

    usemin:
      html: ['build/<%= relativePath %>/index.html', 'build/<%= relativePath %>/<%= relativePath %>/index.html']

    karma:
      options:
        configFile: 'karma.conf.coffee'
      unit:
        background: true
      single:
        singleRun: true

    connect:
      server:
        options:
          livereload: true
          #open: 'http://localhost:80/<%= relativePath %>/'
          hostname: "*"
          port: 80
          middleware: (connect, options) ->
            proxy = require("grunt-connect-proxy/lib/utils").proxyRequest
            [proxy, connect.static('./build/')]
        proxies: [
          context: ['/', '!/<%= relativePath %>']
          host: 'portal.vtexcommerce.com.br'
          headers: {
            "X-VTEX-Router-Backend-EnvironmentType": "beta"
          }
        ]

    watch:
      options:
        livereload: true
        spawn: false
      coffee:
        files: ['src/coffee/**/*.coffee']
        tasks: ['coffee']
      less:
        files: ['src/style/**/*.less']
        tasks: ['less']
      ngtemplates:
        files: ['src/views/**/*.html']
        tasks: ['ngtemplates']
      main:
        files: ['src/i18n/**/*.json', 'src/index.html']
        tasks: ['copy']
      test:
        files: ['src/coffee/**/*.coffee', 'spec/**/*.coffee']
        tasks: ['karma:unit:run']
   
    vtex_deploy:
      main:
        cwd: "build/<%= relativePath %>"
        upload:
          "/{{version}}/": "**"
        transform:
          replace:
            "\<\!\-\-remove\-\-\>(.|\n)*\<\!\-\-endremove\-\-\>" : ""
            "/admin/speedbag/": "//io.vtex.com.br/speedbag/{{version}}/"
            'window.versionDirectory = "";': 'window.versionDirectory = "//io.vtex.com.br/speedbag/{{version}}/";'

          files: ["index.html", "<%= relativePath %>/index.html"]


  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'
  grunt.loadTasks 'tasks'

  grunt.registerTask 'default', ['clean', 'copy', 'coffee', 'less', 'ngtemplates', 'server', 'watch']
  grunt.registerTask 'tdd', ['clean', 'copy', 'coffee', 'less', 'ngtemplates', 'karma:unit', 'server', 'watch']
  grunt.registerTask 'min', ['useminPrepare', 'concat', 'uglify', 'usemin'] # minifies files
  grunt.registerTask 'dist', ['clean', 'copy', 'coffee', 'less', 'ngtemplates', 'min'] # Dist - minifies files
  grunt.registerTask 'devmin', ['dist', 'configureProxies:server', 'connect:server:keepalive'] # Minifies files and serve
  grunt.registerTask 'test', ['karma:single']
  grunt.registerTask 'server', ['configureProxies:server', 'connect']

