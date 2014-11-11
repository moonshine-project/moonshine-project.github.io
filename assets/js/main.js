(function() {
  angular.module('App', ['ngMaterial']).controller('MainController', [
    '$scope', '$mdSidenav', '$timeout', function($scope, $mdSidenav, $timeout) {
      return $scope.openMenu = function() {
        return $timeout(function() {
          return $mdSidenav('left').open();
        });
      };
    }
  ]);

}).call(this);
