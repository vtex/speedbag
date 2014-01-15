angular.module('app').run(['$templateCache', function($templateCache) {
  'use strict';

  $templateCache.put('views/footer.html',
    "<div class=\"footer\"><p>VTEX 2013</p></div>"
  );


  $templateCache.put('views/header.html',
    "<div class=\"page-header\"><h1 translate=\"\">speedbag</h1><p class=\"lead\">The no-nonsense front end boilerplate</p></div>"
  );

}]);
