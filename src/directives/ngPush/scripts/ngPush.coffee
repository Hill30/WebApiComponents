hill30Module.directive 'ngPush', ->
	(scope, element, attrs) ->

		apply = (event) ->
			scope.$apply -> scope.$eval attrs.ngPush
			event.preventDefault()
		
		element.bind 'keydown keypress', (event) ->
			if event.which is 13 or event.which is 32
				apply(event)

		element.bind 'click', (event) ->
			apply(event)
