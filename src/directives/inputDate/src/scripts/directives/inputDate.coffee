hill30Module.directive 'inputDate', ['$document', '$timeout', '$filter', ($document, $timeout, $filter) ->
	inputDateStatic = {}

	inputDateStatic.format = "MM/dd/yyyy"
	inputDateStatic.mask = "mm/dd/yyyy"
	inputDateStatic.dateRegexp = /^(0?[1-9]|[12][0-9]|3[01])\/(0?[1-9]|1[012])\/(199\d)|([2-9]\d{3})$/
	inputDateStatic.showWeeks = "false"
	inputDateStatic.minDate = null
	inputDateStatic.maxDate = "'2014-06-22'"

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

		if attrs.hasOwnProperty('isInvalid')
			isInvalidAttr = 'ng-class="{ \'form-control-invalid\': isInvalid }"'

		html = '
			<input type="text" class="form-control input-sm"
					ng-model="resultValue"
					' + (nameAttr || '') + '
					' + (tabindexAttr || '') + '
					' + (isInvalidAttr || '') + '
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
							show-weeks="' + inputDateStatic.showWeeks + '">
					</datepicker>
				</div>
			</span>
'


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

		if scope.$parent.hasOwnProperty('form') and scope.$parent.form.hasOwnProperty(attrs['name'])
			self.hasDateInitialized = false
			self.parentScopeFormElemnt = scope.$parent.form[attrs['name']]

		scope.toggleDatePickerDialog = () ->
			scope.showDialog = !scope.showDialog

		self.focusAndCloseDatePickerDialog = () ->
			self.input.focus()
			$timeout () ->
				scope.showDialog = false


	inputDateStatic.validateAndCommitValue = (self, value) ->
		filteredValue = $filter('date')(value, inputDateStatic.format)

		self.scope.resultValue = filteredValue
		self.input[0].value = filteredValue

		if self.parentScopeFormElemnt
			if self.hasDateInitialized
				isValid = inputDateStatic.dateRegexp.test(filteredValue)
				self.parentScopeFormElemnt.$setValidity "dateValidator", isValid
			else
				self.hasDateInitialized = true

		inputDateStatic.commitValueChain(self.scope.$parent, self.attrs.value, value)


	inputDateStatic.linking = (self) ->
		scope = self.scope
		element = self.element
		attrs = self.attrs

		scope.$watch 'resultValue', (value) ->
			inputDateStatic.validateAndCommitValue(self, value)
			if scope.showDialog is true then scope.showDialog = false
			self.input.focus()

		self.hideDialogByClickAnywhere = (event) ->
			return if !event
			if $(event.target).parents("[datepicker-click-wrapper]").length or
			!$(event.target).parents("html").length #dhilt: year/month pick makes an island
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
			if event.which is 37
				self.element.find('[ng-click="move(-1)"]').click()
			if event.which is 39
				self.element.find('[ng-click="move(1)"]').click()
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
