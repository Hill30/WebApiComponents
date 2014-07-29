hill30Module.directive "typeahead", ["$timeout", ($timeout) ->

	restrict: "E"
	transclude: true
	replace: true

	template: "<div><form><input ng-model=\"term\" ng-change=\"query()\" type=\"text\" autocomplete=\"off\" class=\"form-control input-sm\"/></form><div ng-transclude></div></div>"

	scope:
		search: "&"
		select: "&"
		items: "="
		term: "="

	controller: ($scope) ->
		self = this
		$scope.items = []
		$scope.hide = false
		self.activate = (item) ->
			$scope.active = item

		self.activateNextItem = ->
			index = $scope.items.indexOf($scope.active)
			self.activate $scope.items[(index + 1) % $scope.items.length]

		self.activatePreviousItem = ->
			index = $scope.items.indexOf($scope.active)
			self.activate $scope.items[(if index is 0 then $scope.items.length - 1 else index - 1)]

		self.isActive = (item) ->
			$scope.active is item

		self.selectActive = ->
			return if not $scope.active
			self.select $scope.active

		self.select = (item) ->
			$scope.hide = true
			$scope.focused = true
			$scope.select item: item

		$scope.isVisible = ->
			not $scope.hide and ($scope.focused or $scope.mousedOver)

		$scope.query = ->
			$scope.hide = false
			$scope.search term: $scope.term

		return

	link: (scope, element, attrs, controller) ->
		$input = element.find("form > input")
		$list = element.find("> div")
		$input.bind "focus", ->
			scope.$apply ->
				scope.focused = true

		$input.bind "blur", ->
			scope.$apply ->
				scope.focused = false

		$list.bind "mouseover", ->
			scope.$apply ->
				scope.mousedOver = true

		$list.bind "mouseleave", ->
			scope.$apply ->
				scope.mousedOver = false

		$input.bind "keyup", (e) ->
			if e.keyCode is 9 or e.keyCode is 13
				scope.$apply controller.selectActive
			if e.keyCode is 27
				scope.$apply ->
					scope.hide = true
					scope.active = null

		$input.bind "keydown", (e) ->
			if e.keyCode is 27
				e.preventDefault()
			if e.keyCode is 13 and not scope.active and scope.hide
				scope.hide = false
				e.preventDefault()
			if e.keyCode is 9 and not scope.hide and scope.active
				e.preventDefault()
			if e.keyCode is 40
				e.preventDefault()
				scope.$apply controller.activateNextItem
			if e.keyCode is 38
				e.preventDefault()
				scope.$apply controller.activatePreviousItem

		scope.$watch "items", (items) ->
			controller.activate (if items.length then items[0] else null)

		scope.$watch "focused", (focused) ->
			if focused
				$timeout (->
					$input.focus()
				), 0, false

		scope.$watch "isVisible()", (visible) ->
			if visible
				pos = $input.position()
				height = $input[0].offsetHeight
				$list.css
					top: pos.top + height
					left: pos.left
					position: "absolute"
					display: "block"
			else
				$list.css "display", "none"
]

hill30Module.directive "typeaheadItem", ->
	require: "^typeahead"

	link: (scope, element, attrs, controller) ->
		item = scope.$eval(attrs.typeaheadItem)
		scope.$watch (->
			controller.isActive item
		), (active) ->
			if active
				element.addClass "active"
			else
				element.removeClass "active"

		element.bind "mouseenter", (e) ->
			scope.$apply ->
				controller.activate item

		element.bind "click", (e) ->
			scope.$apply ->
				controller.select item