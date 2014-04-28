path = require 'path'
knox = require 'knox'
S3Deployer = require 'deploy-s3'
fs = require 'fs'
proxy = require 'grunt-connect-proxy/lib/utils'
mock = require 'connect-mock'

module.exports = (grunt) ->
  pkg = grunt.file.readJSON('package.json')
  relativePath = pkg.paths[0].slice(1)
  deployPath = path.join pkg.deploy, pkg.version

  transform = { replace: {} }
  # Which files should be replaced on deploy
  transform.files = ["build/#{relativePath}/index.html", "build/#{relativePath}/#{relativePath}/index.html"]
  # What should be replace in those files
  transform.replace["\<\!\-\- TOPBAR \-\-\>"] = '<script type="text/javascript" src="/admin-topbar/?loadKnockout=true&loadJquery=false&loadBootstrapCss=false&loadBootstrapResponsiveCss=false&loadBootstrapDropdown=false"></script>'
  transform.replace['window.versionDirectory = "";'] = "window.versionDirectory = '//io.vtex.com.br/#{pkg.name}/#{pkg.version}/';"
  transform.replace["/#{relativePath}/"] = "//io.vtex.com.br/#{pkg.name}/#{pkg.version}/"

  # Replace contents on files before deploy following rules in `transform.replace` map.
  deployCopyProcess = (contents, srcpath) ->
    if srcpath in transform.files
      console.log srcpath
      for k, v of transform.replace
        contents = contents.replace(new RegExp(k, 'g'), v)
    return contents

  # Deploys this project to the S3 vtex-io bucket, accessible from io.vtex.com.br/{package.name}/{package.version}/
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

  # Add proxy and mock middlewares to grunt connect
  middleware = (connect, options) ->
    proxy = proxy.proxyRequest
    middlewares = [proxy, connect.static('./build/')]
    middlewares.unshift mock(verbose: true) if grunt.option('mock')
    return middlewares

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
      deploy:
        files: [
          expand: true
          cwd: "build/#{relativePath}/"
          src: ['**']
          dest: deployPath
        ]
        options:
          processContentExclude: ['**/*.{png,gif,jpg,ico,psd}']
          process: deployCopyProcess

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
          middleware: middleware
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
    vtex_deploy: deploy
    # Development tasks
    default: ['build', 'configureProxies:server', 'connect', 'watch']
    devmin: ['build', 'min', 'configureProxies:server', 'connect:server:keepalive'] # Minifies files and serve

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks