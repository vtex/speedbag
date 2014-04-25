path = require 'path'
knox = require 'knox'
S3Deployer = require 'deploy-s3'
fs = require 'fs'
module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')

  relativePath = pkg.paths[0].slice(1)
  transform =
    replace:
      "\<\!\-\- TOPBAR \-\-\>": '<script type="text/javascript" src="/admin-topbar/?loadKnockout=true&loadJquery=false&loadBootstrapCss=false&loadBootstrapResponsiveCss=false&loadBootstrapDropdown=false"></script>'
      'window.versionDirectory = "";': "window.versionDirectory = '//io.vtex.com.br/#{pkg.name}/#{pkg.version}/';"
  
    files: ["build/#{relativePath}/index.html", "build/#{relativePath}/#{relativePath}/index.html"]

  transform.replace["/#{relativePath}/"] = "//io.vtex.com.br/#{pkg.name}/#{pkg.version}/"

  deploy = ->
    done = @async()
    dryRun = grunt.option('dry-run')
    if dryRun
      credentials = {key: 1, secret: 2}
    else
      credentials = JSON.parse fs.readFileSync '/credentials.json'
    credentials.bucket = 'vtex-io'
    client = knox.createClient credentials
    deployer = new S3Deployer(pkg, client, dryrun: dryRun)
    deployer.deploy().then done, done, console.log

  # Project configuration.
  grunt.initConfig

  # Tasks
    clean:
      main: ['build', 'deploy']

    copy:
      main:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**', '!coffee/**', '!style/**', '!views/**']
          dest: "build/#{relativePath}/"
        ,
          src: ['package.json']
          dest: "build/#{relativePath}/package.json"
        ,
          # Serve index.html where janus expects it
          src: ['src/index.html']
          dest: "build/#{relativePath}/#{relativePath}/index.html"
        ]
      deploy:
        files: [
          expand: true
          cwd: "build/#{relativePath}/"
          src: ['**']
          dest: path.join(pkg.deploy, pkg.version)
        ]
        options:
          processContentExclude: ['**/*.{png,gif,jpg,ico,psd}']
          process: (contents, srcpath) ->
            if srcpath in transform.files
              console.log srcpath
              for k, v of transform.replace
                contents = contents.replace(new RegExp(k, 'g'), v)
            return contents

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
          src: ['main.less', 'print.less']
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
          middleware: (connect, options) ->
            proxy = require("grunt-connect-proxy/lib/utils").proxyRequest
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

  console.log grunt.config.data.usemin.html

  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'

  # Build block tasks
  grunt.registerTask 'build', ['clean', 'copy:main', 'nginclude', 'coffee', 'less', 'ngtemplates']
  grunt.registerTask 'min', ['useminPrepare', 'concat', 'uglify', 'usemin'] # minifies files

  # Deploy tasks
  grunt.registerTask 'dist', ['build', 'min', 'copy:deploy'] # Dist - minifies files
  grunt.registerTask 'test', []
  grunt.registerTask 'vtex_deploy', deploy

  # Development tasks
  grunt.registerTask 'default', ['build', 'configureProxies:server', 'connect', 'watch']
  grunt.registerTask 'devmin', ['build', 'min', 'configureProxies:server', 'connect:server:keepalive'] # Minifies files and serve
