'use strict';

angular.module('vlcSyncApp')
  .controller('MainCtrl', ($scope, $http, $timeout) ->
    $scope.channel = new DataChannel('VLC')
    $scope.connected = false

    $scope.channel.onopen = (userid) ->
      $scope.connected = true
      $scope.$apply()

    $scope.channel.onmessage = (message, userid) ->
      console.log message
      $scope.vlcInstance.playing = message.playing
      $.getJSON "http://127.0.0.1:9393/status/#{$scope.port}/pl_pause", (data) ->
        #alert data.time
      $scope.$apply()

    $scope.channel.onleave = (userid) ->
      $scope.connected = false
      $scope.$apply()

    $scope.port = 8080
    $scope.vlcInstance =
      playing: false

    $scope.play = () ->
      $.getJSON "http://127.0.0.1:9393/status/#{$scope.port}/pl_pause", (data) ->
        #alert data.time
      $scope.vlcInstance.playing = true

      $scope.channel.send({ playing: $scope.vlcInstance.playing })

    $scope.pause = () ->
      $.getJSON "http://127.0.0.1:9393/status/#{$scope.port}/pl_pause", (data) ->
        #alert data.time
      $scope.vlcInstance.playing = false
      $scope.channel.send({ playing: $scope.vlcInstance.playing })

    $scope.updateVlcInstace = (data) ->
      if data.state == "playing"
        $scope.vlcInstance.playing = true
      else
        $scope.vlcInstance.playing = false

      $scope.$apply()

    do serverPolling = () ->
      $http({method: 'GET', url: "http://127.0.0.1:9393/status/#{$scope.port}"})
        .success (data, status, headers, config) ->
          $scope.updateVlcInstace data
          $timeout serverPolling, 1000
        #TODO: Handle errors
  )
