hill30Module.directive 'popup', ['$timeout', ($timeout) ->
	restrict: 'AE'
	templateUrl: 'views/vendors/Hill30/popupTemplate.html'
	replace: true
	transclude: true
	link: ($scope, element, attrs, controller) ->
		$scope.popup = {}
		$scope.popup.list = []
		popupIdLast = 0
		ttlDefault = 1500
		doCaptionDefault = 'Ok'

		isEqual = (p1, p2) ->
			return if (p1.type or p2.type) and p1.type isnt p2.type
			return if (p1.text or p2.text) and p1.text isnt p2.text
			if p1.isFunctional or p2.isFunctional
				return if not p2.isFunctional or not p1.isFunctional
				return if p1.doCaption isnt p2.doCaption
			return true


		$scope.popup.show = (popupObj) ->
			popupIdLast++
			popupObj.id = popupIdLast

			ttl = parseInt popupObj.ttl, 10
			if ttl isnt -1
				ttl = if ttl > 0 then ttl else ttlDefault
				$timeout(() ->
					$scope.popup.close popupObj
				, ttl)

			if popupObj.isFunctional
				if not popupObj.do or typeof(popupObj.do) isnt 'function'
					popupObj.isFunctional = false
				else
					popupObj.doCaption = popupObj.doCaption or doCaptionDefault
					popupObj.do = () ->
						$scope.popup.close popupObj
						popupObj.do.call(popupObj)

			if popupObj.hideDuplicates
				for item, index in $scope.popup.list
					if isEqual item, popupObj
						$scope.popup.close item

			$scope.popup.list.push popupObj


		$scope.popup.close = (popupObj) ->
			for item, index in $scope.popup.list
				if item.id is popupObj.id
					$scope.popup.list.splice index, 1
					break

]