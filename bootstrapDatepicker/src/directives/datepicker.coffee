angular.module('app').directive 'datePicker', [
	'$log','$location'
	(console, location) ->
		restrict:'A'
		link: (scope, element, attrs) ->
			element.datepicker( format: 'mm/dd/yyyy' ).on('changeDate', (e) ->
				scope.terminated =  ('0' + (e.date.getMonth()+1)).slice(-2) + '/' + ('0' + e.date.getDate()).slice(-2)  + '/' + e.date.getFullYear()
				scope.$apply()
			)
]