hill30Module.directive 'datePicker', [
	'$log','$location', '$parse'
	(console, location, $parse) ->
		restrict:'A'
		require: '^ngModel'
		link: (scope, element, attrs, ctrl) ->
			parsed = $parse(attrs.ngModel)
			element.datepicker( format: 'yyyy-dd-mm' ).on 'changeDate', (e) ->
				date = e.date.getFullYear() + "-" + ('0' + e.date.getDate()).slice(-2) + "-" + ('0' + (e.date.getMonth()+1)).slice(-2) 
				scope.$apply () -> parsed.assign(scope, date)
]