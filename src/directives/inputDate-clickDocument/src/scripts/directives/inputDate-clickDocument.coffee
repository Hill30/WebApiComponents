hill30Module.directive 'inputDate-clickDocument', ['$document', '$timeout', ($document, $timeout) ->
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

				<span datepicker-click-wrapper>
					<span class="input-group-btn">
						<button class="btn btn-default btn-sm" tabindex="-1" ng-click="toggleDatePickerDialog($event)">
							<i class="glyphicon glyphicon-calendar"></i>
						</button>
					</span>

					<div class="datepicker-wrap" ng-show="showDialog">
						<datepicker
								datepicker-popup="' + format + '"
								ng-model="resultValue"
								show-weeks="' + showWeeks + '">
						</datepicker>
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
		scope.showDialog = false

		self.input = element.find("input")
		self.dropdownWrapper = element.find("[data-dropdown-wrapper]")

		scope.toggleDatePickerDialog = () ->
			scope.showDialog = !scope.showDialog

		self.focusAndCloseDatePickerDialog = () ->
			self.input.focus()
			$timeout () ->
				scope.showDialog = false


	inputDateStatic.linking = (self) ->
		scope = self.scope
		element = self.element
		attrs = self.attrs

		scope.$watch 'resultValue', (value) ->
			inputDateStatic.commitValueChain(scope.$parent, attrs.value, value)
			scope.showDialog = false if scope.showDialog is true
			self.input.focus()

		self.hideDialogByClickAnywhere = (event) ->
			return if !event
			if $(event.target).parents("[datepicker-click-wrapper]").length
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
