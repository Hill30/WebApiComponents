hill30Module.directive 'changeTimeout', [
  '$log'
  (console) ->
    restrict:'A'
    scope:
      model: "=changeTimeout"
      changeTimeoutFunction: "&"
    link: (scope, element, attrs) ->
      element.val scope.model
      timeout = undefined
      element.on "keyup paste search", ->
        clearTimeout timeout
        timeout = setTimeout(->
          scope.model = element[0].value
          scope.changeTimeoutFunction()
          scope.$apply()
        , attrs.delay or 500)
]