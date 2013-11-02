angular.module('timeFilters', []).
  # Converts the seconds passed to a string in the form MM:SS
  filter('secToMins', () ->
    (input) ->
      min = parseInt(input / 60, 10)
      sec = input % 60
      "#{min}:#{sec}"
  )