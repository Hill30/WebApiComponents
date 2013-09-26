hill30Module.directive 'datePicker', [
	'$log','$location', '$parse'
	(console, location, $parse) ->
		restrict:'A'
		require: '^ngModel'
		link: (scope, element, attrs, ctrl) ->
			parsed = $parse(attrs.ngModel)
			element.datepicker( format: 'mm/dd/yyyy' ).on 'changeDate', (e) ->
				date = ('0' + (e.date.getMonth()+1)).slice(-2) + '/' + ('0' + e.date.getDate()).slice(-2)  + '/' + e.date.getFullYear()
				scope.$apply () -> parsed.assign(scope, date)
]