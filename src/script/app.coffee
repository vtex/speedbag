app = angular.module 'app',
  [
    'ngRoute',
    'ngAnimate',
    'pascalprecht.translate',
    'ui.bootstrap'
  ]

app.config ($translateProvider) ->
  $translateProvider.useStaticFilesLoader
    prefix: '/speedbag/i18n/'
    suffix: '.json'

  $translateProvider.preferredLanguage 'pt-BR'

angular.element(document).ready ->
  angular.bootstrap angular.element('#app-container'), ['app']
