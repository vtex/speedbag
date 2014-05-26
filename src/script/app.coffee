
angular.module('app', ['ngRoute', 'ngAnimate', 'pascalprecht.translate', 'ui.bootstrap'])
  .config ($translateProvider) ->
    versionDirectory = if window.versionDirectory is undefined then 'base/src/' else ''
    $translateProvider.useStaticFilesLoader
      prefix: versionDirectory + 'i18n/'
      suffix: '.json'

    $translateProvider.preferredLanguage 'pt-BR'

angular.element(document).ready ->
  angular.bootstrap angular.element('#app-container'), ['app']
