hill30Module.directive 'inputDate', ['$timeout', '$filter', ($timeout, $filter) ->
	inputDateStatic = {}

	inputDateStatic.format = "MM/dd/yyyy"
	inputDateStatic.mask = "mm/dd/yyyy"
	inputDateStatic.dateRegexp = /^(0?[1-9]|[12][0-9]|3[01])\/(0?[1-9]|1[012])\/(199\d)|([2-9]\d{3})$/
	inputDateStatic.showWeeks = "false"

	inputDateStatic.generateTemplate = (element, attrs) ->

		if !attrs.hasOwnProperty('value')
			console.log('inputDate ng-model binding error (value not declared)')
			return

		if attrs.hasOwnProperty('name') and attrs['name'] isnt ""
			nameAttr = 'name = "' + attrs['name'] + '"'

		if parseInt(attrs['tabindex']) isnt NaN
			tabindexAttr = 'tabindex = "' + parseInt(attrs['tabindex']) + '"'
			element.removeAttr('tabindex')

		if attrs.hasOwnProperty('required') and attrs['required'] isnt "false"
			requiredAttr = 'ng-required="true"'

		if attrs.hasOwnProperty('ngDisabled')
			disabledAttr = 'ng-disabled="disabled"'

		html = '
			<div class="input-group">
				<input 
					type="text" 
					class="form-control"
					ng-model="resultValue"
					' + (nameAttr || '') + '
					' + (tabindexAttr || '') + '
					' + (requiredAttr || '') + '
					' + (disabledAttr || '') + '
				/>

				<div class="input-group-btn" data-dropdown-wrapper>

					<button type="button" tabindex="-1" class="btn btn-default dropdown-toggle"
						data-toggle="dropdown"
						data-dropdown-toggler
						' + (disabledAttr || '') + '>
						<i class="glyphicon glyphicon-calendar"></i>
					</button>

					<div class="dropdown-menu">

						<div class="datepicker-wrap" ng-click="$event.stopPropagation()">

							<datepicker
							ng-model="resultValue"
							datepicker-popup="' + inputDateStatic.format + '"
							show-weeks="' + inputDateStatic.showWeeks + '">
							</datepicker>

							<div class="datepicker-button-bar">
								<a class="btn btn-info btn-sm" ng-click="setToday()" data-dropdown-today>Today</a>
							</div>

						</div>

					</div>

				</div>

			</div>
'


	inputDateStatic.getValueChain = (targetScope, target) -> #todo dhilt : think about move to global service
		if target.indexOf('.') is -1
			return targetScope[target]

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


	inputDateStatic.commitValueChain = (targetScope, target, value) -> #todo dhilt : think about move to global service
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
		scope.disabled = inputDateStatic.getValueChain(scope.$parent, attrs['ngDisabled'])

		scope.setToday = () ->
			scope.resultValue = new Date()

		self.inputElement = element.find("input")
		self.inputElement.inputmask(inputDateStatic.mask)

		self.wrapperElement = self.element.find("[data-dropdown-wrapper]")
		self.togglerElement = self.element.find("[data-dropdown-toggler]")

		if scope.$parent.hasOwnProperty('form') and scope.$parent.form.hasOwnProperty(attrs['name'])
			self.hasDateInitialized = false
			self.parentScopeFormElemnt = scope.$parent.form[attrs['name']]

		self.focusAndCloseDatePickerDialog = () ->
			return if !self.wrapperElement.hasClass('open')
			self.inputElement.focus()
			self.togglerElement.click()


	inputDateStatic.validateAndCommitValue = (self, value) ->
		scope = self.scope
		filteredValue = $filter('date')(value, inputDateStatic.format)

		scope.resultValue = filteredValue
		self.inputElement[0].value = filteredValue

		if self.parentScopeFormElemnt
			if self.hasDateInitialized
				isValid = inputDateStatic.dateRegexp.test(filteredValue)
				self.parentScopeFormElemnt.$setValidity "dateValidator", isValid
			else
				self.hasDateInitialized = true

		inputDateStatic.commitValueChain(scope.$parent, self.attrs.value, filteredValue)


	inputDateStatic.linking = (self) ->
		scope = self.scope
		element = self.element
		attrs = self.attrs

		scope.$watch 'resultValue', (value) ->
			inputDateStatic.validateAndCommitValue(self, value)
			self.focusAndCloseDatePickerDialog()

		if attrs['updateFromCtrl']
			scope.$parent.$watch attrs['updateFromCtrl'], (options) ->
				scope.resultValue = if options then options.value else ''

		if attrs['ngDisabled']
			scope.$parent.$watch attrs['ngDisabled'], (value) ->
				scope.disabled = value

		handleKey = (event) ->
			if event.which is 37
				self.element.find('[ng-click="move(-1)"]').click()
			if event.which is 39
				self.element.find('[ng-click="move(1)"]').click()
			if event.which is 27
				self.focusAndCloseDatePickerDialog()
			else if event.which is 9
				self.focusAndCloseDatePickerDialog()
			return true

		element.bind 'keydown', handleKey

		scope.$on "$destroy", () ->
			element.unbind 'keydown', handleKey


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

]
