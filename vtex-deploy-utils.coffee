fs = require 'fs'
path = require 'path'
knox = require 'knox'
S3Deployer = require 'deploy-s3'
glob = require 'glob'

transform = { replace: {} }
replaceIn = (files) ->
  transform.files = files
replace = (key, value) ->
  transform.replace[key] = value

module.exports = (pkg, options) ->
  deployPath = path.join pkg.deploy, pkg.version
  relativePath = pkg.paths[0].slice(1)
  options.dryRun or= false

  # Deploys this project to the S3 vtex-io bucket, accessible from io.vtex.com.br/{package.name}/{package.version}/
  deployFunction = ->
    done = @async()
    if options.dryRun
      credentials = {key: 1, secret: 2}
    else
      credentials = JSON.parse fs.readFileSync '/credentials.json'
    credentials.bucket = 'vtex-io'
    client = knox.createClient credentials
    deployer = new S3Deployer(pkg, client, dryrun: options.dryRun)
    deployer.deploy().then done, done, console.log

  copyDeployConfig =
    files: [
      expand: true
      cwd: "build/#{relativePath}/"
      src: ['**']
      dest: deployPath
    ]
    options:
      processContentExclude: ['**/*.{png,gif,jpg,ico,psd}']
      # Replace contents on files before deploy following rules in options.replace.map.
      process: (contents, srcpath) ->
        replaceFiles = if options.replace then glob.sync options.replace.glob else []
        for file in replaceFiles
          if file.indexOf(srcpath) >= 0
            console.log "Replacing file...", file
            for k, v of options.replace.map
              contents = contents.replace(new RegExp(k, 'g'), v)
        return contents

  return  {
    deployFunction: deployFunction
    copyDeployConfig: copyDeployConfig
  }
