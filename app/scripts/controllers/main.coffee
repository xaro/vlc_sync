'use strict';

angular.module('vlcSyncApp')
  .controller 'MainCtrl', ($scope, $http, $timeout, $routeParams) ->
    $scope.started = false
    $scope.connected = false

    $scope.port = 8080
    $scope.serverPort = 9393
    $scope.processing = false
    $scope.localUser =
      name: "User#{Math.floor(Math.random()*100)}"
      id: (Math.round(Math.random() * 60535) + 5000000)
      vlcInstance:
        playing: false
        timer: 0
        title: ""
    $scope.remoteUsers = {}

    $scope.channel = new DataChannel($routeParams.roomId,
      userid: $scope.localUser.id
    )

    $scope.channel.onopen = (userid) ->
      $scope.connected = true
      $scope.$apply()

      $scope.channel.send
        type: "handshake"
        user: $scope.localUser

    $scope.channel.onmessage = (message, userid) ->
      if $scope.localUser.id != message.user.id
        $scope.processing = true
        $scope.remoteUsers[userid] =
          name: message.user.name
          id: userid
          vlcInstance: message.user.vlcInstance
        
        if message.action == "play" && !$scope.localUser.vlcInstance.playing
          $.getJSON "http://127.0.0.1:#{$scope.serverPort}/status/#{$scope.port}/pl_pause", (data) ->
            $scope.localUser.vlcInstance.playing = true
            $scope.processing = false
        else if message.action == "pause" && $scope.localUser.vlcInstance.playing
          $.getJSON "http://127.0.0.1:#{$scope.serverPort}/status/#{$scope.port}/pl_pause", (data) ->
            $scope.localUser.vlcInstance.playing = false
            $scope.processing = false
        else
            $scope.processing = false

        $scope.$apply()

    $scope.channel.onleave = (userid) ->
      $scope.connected = false
      $scope.$apply()

    $scope.play = () ->
      $scope.processing = true
      $scope.localUser.vlcInstance.playing = true
      $.getJSON "http://127.0.0.1:#{$scope.serverPort}/status/#{$scope.port}/pl_pause", (data) ->
        $scope.updateVlcInstace data
        $scope.channel.send
          type: "playback"
          action: "play"
          user: $scope.localUser
        $scope.processing = false

    $scope.pause = () ->
      $scope.processing = true
      $scope.localUser.vlcInstance.playing = false
      $.getJSON "http://127.0.0.1:#{$scope.serverPort}/status/#{$scope.port}/pl_pause", (data) ->
        $scope.updateVlcInstace data
        $scope.channel.send
          type: "playback"
          action: "pause"
          user: $scope.localUser
        $scope.processing = false

    $scope.updateVlcInstace = (data) ->
      syncNeeded = false

      if data.state == "playing" && !$scope.localUser.vlcInstance.playing
        $scope.localUser.vlcInstance.playing = true
        syncNeeded = true
        action = "play"
      else if data.state == "paused" && $scope.localUser.vlcInstance.playing
        $scope.localUser.vlcInstance.playing = false
        syncNeeded = true
        action = "pause"
      
      if data.state == "stopped" && $scope.localUser.vlcInstance.title != "Not playing"
        $scope.localUser.vlcInstance.title = "Not playing"
        syncNeeded = true
        action = "stop"
      else if $scope.localUser.vlcInstance.title != data.information.category.meta.filename
        $scope.localUser.vlcInstance.title = data.information.category.meta.filename
        syncNeeded = true
      
      $scope.localUser.vlcInstance.timer = data.time

      if syncNeeded && !$scope.processing && $scope.connected
        $scope.channel.send
          type: "playback"
          action: action
          user: $scope.localUser

    $scope.startSync = () ->
      do serverPolling = () ->
        $http({method: 'GET', url: "http://127.0.0.1:#{$scope.serverPort}/status/#{$scope.port}"})
          .success (data, status, headers, config) ->
            $scope.updateVlcInstace data
            $timeout serverPolling, 1000
          #TODO: Handle errors