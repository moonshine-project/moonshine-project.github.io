---
---

angular.module 'App', ['ngMaterial']
  .controller 'MainController', ['$scope', '$mdSidenav', '$timeout', ($scope, $mdSidenav, $timeout) ->
    $scope.openMenu = ->
      $timeout ->
        $mdSidenav('left').open()
  ]
