'use strict';

angular.module('vlcSyncApp', ["timeFilters"])
  .config(function($routeProvider) {
    $routeProvider
      .when('/', {
        redirectTo: '/' + Math.random().toString(36).substring(7)
      })
      .when('/:roomId', {
        templateUrl: 'views/main.html',
        controller: 'MainCtrl'
      })
      .otherwise({
        redirectTo: '/'
      });
  })
  .config(['$httpProvider', function($httpProvider) {
    delete $httpProvider.defaults.headers.common["X-Requested-With"]
  }]);