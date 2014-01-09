hill30Module.directive 'datePicker', [
	'$log','$location', '$parse'
	(console, location, $parse) ->
		restrict:'A'
		require: '^ngModel'
		link: (scope, element, attrs, ctrl) ->
			parsed = $parse(attrs.ngModel)
			element.datepicker( format: 'mm/dd/yyyy' ).on 'changeDate', (e) ->
				date = ('0' + ($(element).data('datepicker').getDate()+1)).slice(-2) + '/' + ('0' + $(element).data('datepicker').getDate()).slice(-2)  + '/' + $(element).data('datepicker').getDate()
				scope.$apply () -> parsed.assign(scope, date)
				scope.$emit("#{attrs.ngModel}Event", { date: date })
				element.datepicker("hide")
]