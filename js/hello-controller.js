(function() {
  angular.module('app').controller('HelloController', [
    '$scope', function($scope) {
      return $scope.awesomeThings = ['Hello', 'World', '!'];
    }
  ]);

}).call(this);
