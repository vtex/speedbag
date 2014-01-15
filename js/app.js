(function() {
  angular.module('app', ['ngRoute', 'ngAnimate', 'pascalprecht.translate', 'ui.bootstrap']).config(function($translateProvider) {
    var versionDirectory;
    versionDirectory = window.versionDirectory === void 0 ? 'base/src/' : '';
    $translateProvider.useStaticFilesLoader({
      prefix: versionDirectory + 'i18n/',
      suffix: '.json'
    });
    return $translateProvider.preferredLanguage('pt-BR');
  });

  angular.element(document).ready(function() {
    return angular.bootstrap(angular.element('#app-container'), ['app']);
  });

}).call(this);
