hill30Module.directive 'inputDateDropdown', ['$filter', ($filter) ->
	inputDateStatic = {}

	inputDateStatic.format = "MM/dd/yyyy"
	inputDateStatic.mask = "mm/dd/yyyy"
	inputDateStatic.showWeeks = "false"
	inputDateStatic.minDate = null
	inputDateStatic.maxDate = "'2014-06-22'"

	inputDateStatic.generateTemplate = (element, attrs) ->

		if !attrs.hasOwnProperty('value')
			console.log('inputDate ng-model binding error (value not declared)')
			return

		if parseInt(attrs['tabindex']) isnt NaN
			tabindexAttr = 'tabindex = "' + parseInt(attrs['tabindex']) + '"'
			element.attr('tabindex', '')

		if attrs.hasOwnProperty('required') and attrs['required'] isnt "false"
			requiredAttr = 'ng-required="true"'

		if attrs.hasOwnProperty('doEnter')
			doEnterAttr = 'ng-enter="doEnter()"'

		if attrs.hasOwnProperty('isInvalid')
			isInvalidAttr = 'ng-class="{ \'form-control-invalid\': isInvalid }"'

		html = '
					<input type="text" class="form-control input-sm"
							ng-model="resultValue"
							' + tabindexAttr + '
							' + doEnterAttr + '
							' + isInvalidAttr + '
							/>

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
										datepicker-popup="' + inputDateStatic.format + '"
										ng-model="resultValue"
										show-weeks="' + inputDateStatic.showWeeks + '">
								</datepicker>
							</div>

						</div>
					</span>
		'

		return html


	inputDateStatic.getValueChain = (targetScope, target) -> #todo dhilt : need to generalize method
		chain = target.split('.')
		lastRing = chain[chain.length - 1]
		src = targetScope;

		for ring in chain
			if ring is lastRing
				break
			if !src.hasOwnProperty(ring)
				console.log 'Chain walk error: can\'t find "' + ring + '" property within "' + chain + '" chain';
				return
			src = src[ring]

		return src[lastRing]


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

		scope.format = inputDateStatic.format

		self.input = element.find("input")
		self.input.inputmask(inputDateStatic.mask)

		self.hideDatePicker = () ->
			if $._data(document, "events").click
				$._data(document, "events").click[0].handler()

		doEnter = inputDateStatic.getValueChain(scope.$parent, attrs['doEnter']) if attrs['doEnter']
		if doEnter
			scope.doEnter = () ->
				doEnter.call(scope.$parent)


	inputDateStatic.linking = (self) ->
		scope = self.scope
		element = self.element
		attrs = self.attrs

		scope.$watch 'resultValue', (value) ->
			filteredValue = $filter('date')(value, inputDateStatic.format)
			scope.resultValue = filteredValue
			self.input[0].value = filteredValue

			inputDateStatic.commitValueChain(scope.$parent, attrs.value, value)
			self.hideDatePicker()
			self.input.focus()

		element.bind 'keydown', (event) ->
			if event.which is 27
				self.hideDatePicker()
				self.input.focus()
			else if event.which is 9
				self.hideDatePicker()
			return true


	return {

	restrict: 'E'

	template: (element, attrs) ->
		inputDateStatic.generateTemplate(element, attrs)

	transclude: true

	scope: {
		isInvalid: '='
	}

	link: (scope, element, attrs) ->
		self = {}
		self.scope = scope
		self.element = element
		self.attrs = attrs

		inputDateStatic.initialize(self)
		inputDateStatic.linking(self)

	}

]
