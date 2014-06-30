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

		$scope.popup.show = (popupObj) ->
			popupIdLast++
			popupObj.id = popupIdLast

			ttl = parseInt popupObj.ttl, 10
			if ttl isnt -1
				ttl = if ttl > 0 then ttl else ttlDefault
				$timeout(() ->
					$scope.popup.close popupObj
				, ttl)

			if popupObj.hideDuplicates
				for item, index in $scope.popup.list
					if item.type is popupObj.type and item.text is popupObj.text
						$scope.popup.close item

			$scope.popup.list.push popupObj

		$scope.popup.close = (popupObj) ->
			for item, index in $scope.popup.list
				if item.id is popupObj.id
					$scope.popup.list.splice index, 1
					break

]