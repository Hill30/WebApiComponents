hill30Module.directive 'inputDate', ['$document', '$timeout', '$filter', ($document, $timeout, $filter) ->
	inputDateStatic = {}

	inputDateStatic.format = "MM/dd/yyyy"
	inputDateStatic.mask = "mm/dd/yyyy"

	inputDateStatic.generateTemplate = (element, attrs) ->
		minDate = null
		maxDate = "'2014-06-22'"
		showWeeks = "false"

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
					' + (tabindexAttr || '') + '
					' + doEnterAttr + '
					' + isInvalidAttr + '
					/>

			<span datepicker-click-wrapper style="position: absolute;">
				<span class="input-group-btn">
					<button class="btn btn-default btn-sm" tabindex="-1" ng-click="toggleDatePickerDialog($event)">
						<i class="glyphicon glyphicon-calendar"></i>
					</button>
				</span>

				<div class="datepicker-wrap" ng-show="showDialog">
					<datepicker
							ng-model="resultValue"
							show-weeks="' + showWeeks + '">
					</datepicker>
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


	inputDateStatic.commitValueChain = (targetScope, target, value) -> #todo dhilt : need to generalize method
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
		scope.showDialog = false

		scope.format = inputDateStatic.format

		self.input = element.find("input")
		self.input.inputmask(inputDateStatic.mask)

		scope.toggleDatePickerDialog = () ->
			scope.showDialog = !scope.showDialog

		self.focusAndCloseDatePickerDialog = () ->
			self.input.focus()
			$timeout () ->
				scope.showDialog = false

		doEnter = inputDateStatic.getValueChain(scope.$parent, attrs['doEnter']) if attrs['doEnter']
		if doEnter
			scope.doEnter = () ->
				doEnter.call(scope.$parent) # todo dhilt : think about params passing


	inputDateStatic.linking = (self) ->
		scope = self.scope
		element = self.element
		attrs = self.attrs

		scope.$watch 'resultValue', (value) ->

			#todo dhilt: 're you sure you need to format date manually?
			filteredValue = $filter('date')(value, inputDateStatic.format)
			scope.resultValue = filteredValue
			self.input[0].value = filteredValue

			inputDateStatic.commitValueChain(scope.$parent, attrs.value, value)
			scope.showDialog = false if scope.showDialog is true
			self.input.focus()

		self.hideDialogByClickAnywhere = (event) ->
			return if !event
			if $(event.target).parents("[datepicker-click-wrapper]").length or
			!$(event.target).parents("html").length #todo dhilt: year/month pick makes an island
				event.stopPropagation()
				event.preventDefault()
				return
			$timeout () ->
				scope.showDialog = false

		self.bindClickDocument = () ->
			return if self.hasDocumentClickBound
			self.hasDocumentClickBound = true
			$document.bind('click', self.hideDialogByClickAnywhere)

		self.unbindClickDocument = () ->
			self.hasDocumentClickBound = false
			$document.unbind('click', self.hideDialogByClickAnywhere)

		scope.$watch 'showDialog', (value) ->
			if value is true
				self.bindClickDocument()
			else
				self.unbindClickDocument()

		element.bind 'keydown', (event) ->
			if event.which is 27
				self.focusAndCloseDatePickerDialog()
			else if event.which is 9
				if scope.showDialog is true
					self.focusAndCloseDatePickerDialog()
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
