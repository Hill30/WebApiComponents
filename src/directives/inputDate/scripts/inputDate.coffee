hill30Module.directive 'inputDate', ['$timeout', '$filter', ($timeout, $filter) ->
	inputDateStatic = {}

	inputDateStatic.format = "MM/dd/yyyy"
	inputDateStatic.mask = "mm/dd/yyyy"
	inputDateStatic.dateRegexp = /^(0?[1-9]|1[012])\/(0?[1-9]|[12][0-9]|3[01])\/((199\d)|([2-9]\d{3}))$/
	inputDateStatic.showWeeks = "false"
	inputDateStatic.defaultDebounceDelay = 350
	inputDateStatic.defaultAutocommit = "lostFocus"

	inputDateStatic.generateTemplate = (element, attrs) ->

		if !attrs.hasOwnProperty('value')
			console.log('inputDate ng-model binding error (value not declared)')
			return

		if attrs.hasOwnProperty('name') and attrs['name'] isnt ""
			nameAttr = 'name = "' + attrs['name'] + '"'

		if not isNaN parseInt(attrs['tabindex'], 10)
			tabindexAttr = 'tabindex = "' + parseInt(attrs['tabindex']) + '"'
			element.removeAttr('tabindex')

		if attrs.hasOwnProperty('required') and attrs['required'] isnt "false"
			requiredAttr = 'ng-required="true"'

		if attrs.hasOwnProperty('ngDisabled')
			disabledAttr = 'ng-disabled="disabled"'

		maskAttr = 'inputmask-date';
		if not attrs.hasOwnProperty('maskType') or attrs['maskType'] isnt 'jquery.inputmask'
			maskAttr = 'ui-mask="99/99/9999" placeholder="' + inputDateStatic.mask + '"';

		attrs['autocommit'] ?= ''

		html = '
			<div class="input-group">
				<input
					type="text"
					class="form-control"
					ng-model="inputValue"
					' + (maskAttr || '') + '
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
							ng-model="pickerValue"
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
		src = targetScope

		for ring in chain
			break if ring is lastRing
			if !angular.isDefined(src[ring])
				console.log 'Chain walk error: can\'t find "' + ring + '" property within "' + chain + '" chain';
				return
			src = src[ring]

		return src[lastRing]


	inputDateStatic.commitValueChain = (targetScope, target, value) -> #todo dhilt : think about move to global service
		chain = target.split('.')
		lastRing = chain[chain.length - 1]
		src = targetScope

		for ring in chain
			break if ring is lastRing
			if !angular.isDefined(src[ring])
				console.log 'Chain walk error: can\'t find "' + ring + '" property within "' + chain + '" chain';
				return false
			src = src[ring]

		src[lastRing] = value
		return true


	inputDateStatic.debounce = (fn, wait) ->
		args = context = result = timeout = null

		ping = () ->
			result = fn.apply(context, args)
			context = args = null

		cancel = () ->
			if timeout
				$timeout.cancel(timeout)
				timeout = null

		wrapper = () ->
			context = this
			args = arguments
			cancel()
			timeout = $timeout(ping, wait)

		wrapper.flush = () ->
			if (context)
				cancel()
				ping()
			else if !timeout
				ping()
			result

		wrapper


	inputDateStatic.initialize = (self) ->
		scope = self.scope
		element = self.element
		attrs = self.attrs

		scope.inputValue = ''
		scope.pickerValue = ''
		scope.resultValue = ''
		scope.disabled = inputDateStatic.getValueChain(scope.$parent, attrs['ngDisabled']) if attrs['ngDisabled']

		formName = if attrs.hasOwnProperty('formName') and attrs['formName'] isnt "" then attrs['formName'] else 'form'
		form = scope.$parent[formName]

		self.autocommit = {}
		self.autocommit.lostFocus = true if attrs['autocommit'].indexOf('lostFocus') isnt -1
		self.autocommit.enter = true if attrs['autocommit'].indexOf('enter') isnt -1
		self.autocommit.input = true if attrs['autocommit'].indexOf('input') isnt -1
		self.autocommit.debouncedInput = true if attrs['autocommit'].indexOf('debouncedInput') isnt -1

		if !self.autocommit.lostFocus and !self.autocommit.enter and !self.autocommit.input and !self.autocommit.debouncedInput
			self.autocommit[inputDateStatic.defaultAutocommit] = true

		scope.setToday = () ->
			# todo dhilt : i don't know why angular don't set $dirty after Today-click automatically...
			form.$dirty = true if form
			self.parentScopeFormElement.$dirty = true if self.parentScopeFormElement
			scope.resultValue = new Date()
			inputDateStatic.prepareValue(self, scope.resultValue);
			self.focusAndCloseDatePickerDialog();
			return inputDateStatic.commitInputValue(self, {
				doNotDigest: true
			});

		self.inputElement = element.find("input")

		# todo dhilt : what about inputmask without jquery ??
		#self.inputElement.inputmask(inputDateStatic.mask)

		self.wrapperElement = angular.element(element[0].querySelector('[data-dropdown-wrapper]'))
		self.togglerElement = angular.element(element[0].querySelector('[data-dropdown-toggler]'))

		if form and form.hasOwnProperty(attrs['name'])
			self.hasDateInitialized = false
			self.parentScopeFormElement = form[attrs['name']]

		self.focusAndCloseDatePickerDialog = () ->
			return if !self.wrapperElement.hasClass('open')
			self.inputElement[0].focus()
			self.togglerElement[0].click()


	inputDateStatic.getDebouncedInputDelay = (param) ->
		defaultDelay = inputDateStatic.defaultDebounceDelay
		return defaultDelay if !param
		str = 'debouncedInput'
		start = parseInt(param.indexOf(str + '('))
		end = parseInt(param.indexOf(')'))
		return defaultDelay if start < 0 or end < 0 or start >= end
		delay = parseInt(param.substr(start + str.length + 1, end - start - str.length - 1))
		return defaultDelay if !(delay > 0)
		delay


	inputDateStatic.prepareValue = (self, value) ->
		filteredValue = $filter('date')(value, inputDateStatic.format)
		self.scope.inputValue = filteredValue;
		self.scope.resultValue = filteredValue
		self.inputElement[0].value = filteredValue
		inputDateStatic.validateValue(self, filteredValue)


	inputDateStatic.validateValue = (self, value) ->
		isValid = true
		if self.hasDateInitialized or !self.parentScopeFormElement
			isValid = inputDateStatic.dateRegexp.test(value)
			if self.parentScopeFormElement
				self.parentScopeFormElement.$setValidity "dateValidator", isValid
		else
			self.hasDateInitialized = true
		isValid


	inputDateStatic.commitInputValue = (self, commitParams = {}) ->
		value = self.inputElement[0].value
		return if value is inputDateStatic.getValueChain(self.scope.$parent, self.attrs.value)
		if inputDateStatic.validateValue(self, value)
			self.scope.resultValue = value
			inputDateStatic.commitValueChain(self.scope.$parent, self.attrs.value, value)
			self.scope.$parent.$digest() if not commitParams.doNotDigest


	inputDateStatic.commitInputValueBy =
		event: (self) ->
			(event) ->
				commitParams = {}
				#todo dhilt: if we fail date and then blur input the exception will throw anyway... because of lost focus changes model (resultValue) immediate
				inputDateStatic.commitInputValue(self, commitParams)
				return false
		eventDebounced: (self) ->
			debouncedCommit = inputDateStatic.debounce(() ->
				inputDateStatic.commitInputValue(self)
			, inputDateStatic.getDebouncedInputDelay(self.attrs['autocommit']))
			(event) ->
				debouncedCommit()
				return false
		enter: (self) ->
			(event) ->
				if event.which is 13
					inputDateStatic.commitInputValue(self)
					return false


	inputDateStatic.linking = (self) ->
		scope = self.scope
		element = self.element
		attrs = self.attrs

		inputElement = self.inputElement
		commitBy = inputDateStatic.commitInputValueBy
		unregisterList = []

		if self.autocommit.lostFocus then inputElement.bind 'blur', commitBy.event(self)
		if self.autocommit.enter then inputElement.bind 'keyup', commitBy.enter(self)
		if self.autocommit.input then inputElement.bind 'propertychange keyup paste', commitBy.event(self)
		else if self.autocommit.debouncedInput then inputElement.bind 'propertychange keyup paste', commitBy.eventDebounced(self)

		unregisterList.push(
			scope.$watch 'pickerValue', (value) ->
				#watch is only for pick date
				if typeof value isnt 'string'
					inputDateStatic.prepareValue(self, value)
					self.focusAndCloseDatePickerDialog()
					inputDateStatic.commitInputValue(self, {
						doNotDigest: true
					})
		)

		if attrs['updateFromCtrl']
			unregisterList.push(
				scope.$parent.$watch attrs['updateFromCtrl'], (options) ->
					scope.inputValue = if options then options.value else ''
					inputElement[0].value = scope.inputValue
					scope.resultValue = scope.inputValue
			)

		if attrs['ngDisabled']
			unregisterList.push(
				scope.$parent.$watch attrs['ngDisabled'], (value) ->
					scope.disabled = value
			)

		handleKey = (event) ->
			return true if event.target.innerHTML is ''
			if event.which is 37
				angular.element(self.element[0].querySelector('[ng-click="move(-1)"]'))[0].click()
			if event.which is 39
				angular.element(self.element[0].querySelector('[ng-click="move(1)"]'))[0].click()
			if event.which is 27
				self.focusAndCloseDatePickerDialog()
			else if event.which is 9
				self.focusAndCloseDatePickerDialog()
			return true

		element.bind 'keyup', handleKey

		scope.$on "$destroy", () ->
			if self.autocommit.lostFocus then inputElement.unbind 'blur', commitBy.event(self)
			if self.autocommit.enter then inputElement.unbind 'keyup', commitBy.enter(self)
			if self.autocommit.input then inputElement.unbind 'propertychange keyup paste', commitBy.event(self)
			else if self.autocommit.debouncedInput then inputElement.unbind 'propertychange keyup paste', commitBy.eventDebounced(self)
			element.unbind 'keyup', handleKey
			unregFunc() for unregFunc in unregisterList


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
