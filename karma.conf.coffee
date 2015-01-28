module.exports = (config) ->
  config.set
    browsers: ['PhantomJS']
    frameworks: ['mocha', 'chai']
    files: [
      'http://io.vtex.com.br/front-libs/angular/1.2.11/angular.min.js'
      'src/script/app.coffee'
      'spec/*.coffee'
    ]
    reporters: ['mocha']
    client:
      mocha:
        ui: 'bdd'
    preprocessors:
      '**/*.coffee': ['coffee']
