DeployUtils = require './vtex-deploy-utils'

module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')
  relativePath = pkg.paths[0].slice(1)
  r = {}
  # Parts of the index we wish to replace on deploy
  r[pkg.paths[0]] = "//io.vtex.com.br/#{pkg.name}/#{pkg.version}"
  r["\<\!\-\- TOPBAR \-\-\>"] = "<script type=\"text/javascript\" src=\"/admin-topbar/?loadKnockout=true&loadJquery=false&loadBootstrapCss=false&loadBootstrapResponsiveCss=false&loadBootstrapDropdown=false\"></script>"
  r["window.versionDirectory = \"\";"] = "window.versionDirectory = '//io.vtex.com.br/#{pkg.name}/#{pkg.version}/';"

  utils = DeployUtils pkg,
    dryRun: grunt.option("dry-run")
    replace:
      map: r
      glob: "build/**/index.html"

  # Tasks
  config =
    clean:
      main: ['build', 'deploy']

    copy:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**', '!views/**', '!partials/**', '!coffee/**', '!**/*.less']
          dest: "build/#{relativePath}/"
        ,
          src: ['package.json']
          dest: "build/#{relativePath}/package.json"
        ,
          # Serve index.html where janus expects it
          src: ['src/index.html']
          dest: "build/#{relativePath}/#{relativePath}/index.html"
        ]
      deploy: utils.copyDeployConfig

    coffee:
      main:
        files: [
          expand: true
          cwd: 'src/coffee'
          src: ['**/*.coffee']
          dest: "build/#{relativePath}/js/"
          ext: '.js'
        ]

    less:
      main:
        files: [
          expand: true
          cwd: 'src/style'
          src: ['style.less', 'print.less']
          dest: "build/#{relativePath}/style/"
          ext: '.css'
        ]

    uglify:
      options:
        mangle: false

    nginclude:
      options:
        assertDirs: ['src/']
      src:
        expand: true
        cwd: 'src/views/'
        src: ['**/*.html']
        dest: "build/#{relativePath}/views/"

    ngtemplates:
      main:
        cwd: "build/#{relativePath}/"
        src: 'views/**/*.html',
        dest: "build/#{relativePath}/js/templates.js"
        options:
          module: 'app'
          htmlmin:  collapseWhitespace: true, collapseBooleanAttributes: true

    useminPrepare:
      html: "build/#{relativePath}/index.html"
      options:
        dest: 'build/'
        root: 'build/'

    usemin:
      html: ["build/#{relativePath}/index.html", "build/#{relativePath}/#{relativePath}/index.html"]

    connect:
      server:
        options:
          livereload: true
          open: "http://localhost:80/#{relativePath}/"
          hostname: "*"
          port: 80
          middleware: (connect) ->
            proxy = require('grunt-connect-proxy/lib/utils').proxyRequest
            middlewares = [proxy, connect.static('./build/')]
            middlewares.unshift require('connect-mock')(verbose: true) if grunt.option('mock')
            return middlewares
        proxies: [
          context: ['/', "!/#{relativePath}"]
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
      templates:
        files: ['src/views/**/*.html', 'src/partials/**/*.html']
        tasks: ['nginclude', 'ngtemplates']
      main:
        files: ['src/i18n/**/*.json', 'src/index.html', 'src/lib/**/*.*']
        tasks: ['copy']

  tasks =
    # Building block tasks
    build: ['clean', 'copy:main', 'nginclude', 'coffee', 'less', 'ngtemplates']
    min: ['useminPrepare', 'concat', 'uglify', 'usemin'] # minifies files
    # Deploy tasks
    dist: ['build', 'min', 'copy:deploy'] # Dist - minifies files
    test: []
    vtex_deploy: utils.deployFunction
    # Development tasks
    default: ['build', 'configureProxies:server', 'connect', 'watch']
    devmin: ['build', 'min', 'configureProxies:server', 'connect:server:keepalive'] # Minifies files and serve

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks