hill30Module.directive 'selectBox', ['$log', '$parse', '$compile', (console, $parse, $compile) ->
	selectBoxStatic = {}

	selectBoxStatic.defaults = {}
	selectBoxStatic.defaults.viewValueId = "id"
	selectBoxStatic.defaults.viewValueName = "name"
	selectBoxStatic.defaults.idListStringPostfix = "IdListString"
	selectBoxStatic.defaults.nameListStringPostfix = "NameListString"


	selectBoxStatic.initialize = (self) ->
		attrs = self.attrs

		if attrs.hasOwnProperty('idListString')
			self.idListString = attrs.idListString
		else
			self.idListString = attrs.ngModel + selectBoxStatic.defaults.idListStringPostfix

		if attrs.hasOwnProperty('nameListString')
			self.nameListString = attrs.nameListString
		else
			self.nameListString = attrs.ngModel + selectBoxStatic.defaults.nameListStringPostfix

		if attrs.hasOwnProperty('tabindex')
			self.tabindex = parseInt(attrs.tabindex, 10)

		if attrs.hasOwnProperty('dynamicSize')
			self.dynamicSize = attrs['dynamicSize']

		self.viewValueName = attrs.viewValueName || selectBoxStatic.defaults.viewValueName
		self.viewValueId = attrs.viewValueId || selectBoxStatic.defaults.viewValueId


	selectBoxStatic.generateTemplate = (self) ->
		scope = self.scope
		element = self.element
		elements = self.elements

		tabindexString = ' tabindex="' + self.tabindex + '"' if self.tabindex
		names = self.nameListString

		elements.wrapper = angular.element("<div class='select-box'></div>")
		elements.dropdown = angular.element('<div class="dropdown"></div>')
		elements.toggler = angular.element('<div data-toggle="dropdown" class="dropdown-toggle"></div>')
		elements.dropdownMenu = angular.element('<div class="dropdown-menu"></div>')
		elements.box = angular.element("<div class='select-box-text'" + tabindexString + "><div class='select-box-tooltip-wrap' ng-show='" + names + "'><div class='select-box-tooltip'>{{ " + names + " }}</div></div> {{ " + names + " }}</div>")

		elements.dropdown.append(elements.toggler)
		elements.dropdown.append(elements.dropdownMenu)
		element.wrap(elements.wrapper)
		element.parent().prepend(elements.dropdown)

		$compile(elements.dropdown.contents())(scope)
		elements.toggler.append(elements.box)
		$compile(elements.box.contents())(scope)

		elements.dropdownMenu.append(element)
		elements.parent = element.parent().parent().parent()


	selectBoxStatic.getValueChain = (targetScope, target) ->
		return null if not targetScope
		chain = target.match(/^([\w]+)\.(.+)$/)
		return targetScope[target] if not chain or chain.length isnt 3
		return selectBoxStatic.getValueChain(targetScope[chain[1]], chain[2])
		

	selectBoxStatic.linking = (self) ->
		elements = self.elements

		closeDropdown = () ->
			return if !elements.dropdown.hasClass('open')
			elements.toggler.click()

		openDropdown = () ->
			return if elements.dropdown.hasClass('open')
			elements.toggler.click()

		handleTabKeyDown = (event) ->
			return true if event.target.tagName isnt 'SELECT'
			if event.which is 9
				closeDropdown()

		handleEscKeyUp = (event) ->
			return true if event.target.tagName isnt 'SELECT'
			if event.which is 27
				closeDropdown()
				elements.box.focus()

		handleEnterKeyUp = (event) ->
			if event.which is 13
				openDropdown()

		handleTogglerClick = () ->
			return if !elements.dropdown.hasClass('open')
			elements.dropdown.find('select').focus()

		handleDropdownClick = (event) ->
			event.stopPropagation()
			return false

		elements.parent.bind 'keydown', handleTabKeyDown
		elements.parent.bind 'keyup', handleEscKeyUp
		elements.box.bind 'keyup', handleEnterKeyUp
		elements.toggler.bind 'click', handleTogglerClick
		elements.dropdownMenu.bind 'click', handleDropdownClick

		if self.dynamicSize
			self.scope.$watch self.dynamicSize, () ->
				self.element.attr('size', selectBoxStatic.getValueChain(self.scope, self.attrs['dynamicSize']))

		self.scope.$on "$destroy", () ->
			elements.parent.unbind 'keydown', handleTabKeyDown
			elements.parent.unbind 'keyup', handleEscKeyUp
			elements.box.unbind 'keyup', handleEnterKeyUp
			elements.toggler.unbind 'click', handleTogglerClick
			elements.dropdownMenu.unbind 'click', handleDropdownClick


	return {

	restrict: 'A'

	require: 'ngModel'

	link: (scope, element, attrs, ctrl) ->
		self = {}
		self.scope = scope
		self.element = element
		self.attrs = attrs
		self.ctrl = ctrl
		self.elements = {}

		selectBoxStatic.initialize(self)
		selectBoxStatic.generateTemplate(self)
		selectBoxStatic.linking(self)

		ctrl.$parsers.unshift (viewValue) ->
			namesArr = []
			idsArr = []
			for item in viewValue
				idsArr.push(item[self.viewValueId]) if item.hasOwnProperty(self.viewValueId)
				namesArr.push(item[self.viewValueName]) if item.hasOwnProperty(self.viewValueName)
			scope[self.idListString] = idsArr.toString()
			scope[self.nameListString] = namesArr.toString()
			$compile(self.elements.box.contents())(scope)
			viewValue

	}

]
