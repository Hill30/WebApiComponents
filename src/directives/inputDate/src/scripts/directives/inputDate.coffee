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

		html = '
			<input type="text" class="form-control input-sm"
					ng-model="resultValue"
					' + (nameAttr || '') + '
					' + (tabindexAttr || '') + '
					' + (requiredAttr || '') + '
					/>

			<span data-dropdown-wrapper class="dropdown" style="position: absolute;">
				<a class="dropdown-toggle ng-binding">
					<span class="input-group-btn">
						<button class="btn btn-default btn-sm" tabindex="-1" data-dropdown-toggler>
							<i class="glyphicon glyphicon-calendar"></i>
						</button>
					</span>
				</a>
				<div class="dropdown-menu">
					<div class="datepicker-wrap" ng-click="$event.stopPropagation()" style="position: relative;">
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
			</span>
'


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
		scope.setToday = () ->
			scope.resultValue = $filter("date")(new Date(), inputDateStatic.format)

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

		inputDateStatic.commitValueChain(scope.$parent, self.attrs.value, value)


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
