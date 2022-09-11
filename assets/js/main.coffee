---
---

angular.module 'App', ['ngMaterial']
  .config ($mdThemingProvider) ->
    $mdThemingProvider.theme('deep-purple')
    .primaryPalette('deep-purple');
  .controller 'MainController', ['$scope', '$mdSidenav', '$timeout', ($scope, $mdSidenav, $timeout) ->
    $scope.openMenu = ->
      $timeout ->
        $mdSidenav('left').open()
  ]
