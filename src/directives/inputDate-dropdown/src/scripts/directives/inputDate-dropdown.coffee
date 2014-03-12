hill30Module.directive 'inputDate-dropdown', () ->
	inputDateStatic = {}


	inputDateStatic.generateTemplate = (element, attrs) ->
		minDate = null
		maxDate = "'2014-06-22'"
		format = "MM/dd/yyyy"
		showWeeks = "false"

		if !attrs.hasOwnProperty('value')
			console.log('inputDate ng-model binding error (value not declared)')
			return

		if parseInt(attrs['tabindex']) isnt NaN
			tabindexAttr = 'tabindex = "' + parseInt(attrs['tabindex']) + '"'
			element.attr('tabindex', '')

		if attrs.hasOwnProperty('required') and attrs['required'] isnt "false"
			requiredAttr = 'ng-required="true"'

		html = '
				<input 	type="text" class="form-control input-sm"
						' + (tabindexAttr || '') + '"
						ng-model="resultValue"
						date-validator
						inputmask-date
						mask="mm/dd/yyyy"/>

				<span class="dropdown" data-dropdown-wrapper style="position: absolute;">
					<a class="dropdown-toggle" data-dropdown-linker>
						<span class="input-group-btn">
							<button class="btn btn-default btn-sm" tabindex="-1">
								<i class="glyphicon glyphicon-calendar"></i>
							</button>
						</span>
					</a>
					<div class="dropdown-menu">

						<div class="datepicker-wrap" ng-click="$event.stopPropagation()" style="position: relative;">
							<datepicker
									datepicker-popup="' + (format || '') + '"
									ng-model="resultValue"
									show-weeks="' + showWeeks + '">
							</datepicker>
						</div>

					</div>
				</span>
										'

		return html

	inputDateStatic.commitValueChain = (targetScope, target, value) ->
		chain = target.split('.')
		lastRing = chain[chain.length - 1]
		src = targetScope;

		for ring in chain
			if ring is lastRing
				break
			if !src.hasOwnProperty(ring)
				console.log 'Chain walk error: can\'t find "' + ring + '" property within "' + chain + '" chain';
				return false
			src = src[ring]

		src[lastRing] = value
		return true


	inputDateStatic.initialize = (self) ->
		scope = self.scope
		element = self.element
		attrs = self.attrs

		scope.resultValue = ''

		scope.showDialog = true

		scope.hideDatePicker = () ->
			scope.showDialog = false
			if $._data(document, "events").click
				$._data(document, "events").click[0].handler()

		scope.$watch 'resultValue', (value) ->
			inputDateStatic.commitValueChain(scope.$parent, attrs.value, value)
			#if scope.showDialog is true
			scope.hideDatePicker()
			self.input.focus()

		scope.$watch 'showDialog', (value) ->
			if value isnt true
				scope.hideDatePicker()

		self.closeDatePicker = () ->
			scope.hideDatePicker()


	inputDateStatic.linking = (self) ->
		scope = self.scope
		element = self.element

		self.input = element.find("input")
		self.dropdownWrapper = element.find("[data-dropdown-wrapper]")

		element.bind 'keydown', (event) ->
			if event.which is 27
				self.closeDatePicker()
				self.input.focus()
			else if event.which is 9
				self.closeDatePicker()
			return true


	return {

	restrict: 'E'

	template: (element, attrs) ->
		inputDateStatic.generateTemplate(element, attrs)

	transclude: true

	scope: {}

	link: (scope, element, attrs) ->
		self = {}
		self.scope = scope
		self.element = element
		self.attrs = attrs

		inputDateStatic.initialize(self)
		inputDateStatic.linking(self)

	}


