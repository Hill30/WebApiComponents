angular.module('app').directive 'select2', [
	'$log','$location', '$injector'
	(console, location, $injector) ->
		require: 'ngModel'
		restrict:'A'

		link: (scope, element, attrs, ctrl) ->
			#init
			attrs.$observe '', (value) ->
				element.select2({ minimumInputLength: attrs.char })
				ngOptions = attrs.ngOptions.split(' ')
				datasource = ngOptions[ ngOptions.length - 1 ]

				inputField = element.parent().find('input')
				if attrs.resource
					inputField.on 'keyup', (e) ->
						if attrs.name
							scope[attrs.name] = $(e.target).val()
							if resource = $injector.get(attrs.resource)
								resource.list { filter: scope[attrs.name] }, (res) ->
									#if attrs.multiple
										#scope[attrs.data] = [] unless scope[attrs.data]		
										#scope[attrs.data].push res
									#	scope.tmp.push scope[attrs.data]
									#	console.log scope.tmp
									scope[datasource] = res

]