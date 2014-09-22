hill30Module.factory('httpInterceptor', ["$q", "$rootScope", ($q, $rootScope) ->

	###response: (response) ->

		#$rootScope.$broadcast "success:#{response.status}", response

		response || $q.when(response)###

	responseError: (response) ->

		#$rootScope.$broadcast "error_#{response.status}", response

		returnObject = {}
		returnObject = $q.reject response

		# error statuses which has to be ignored
		if response.config and response.config.params and response.config.params.ignoreErrors
			ignoreList = response.config.params.ignoreErrors
			if typeof ignoreList isnt "object" or not ignoreList.length
				ignoreList = [ignoreList]
			for ignore in ignoreList
				if response.status is ignore
					return returnObject

		# 403 permission error which leads to permission dialog
		if response.status is 403
			dialogOpenerElement = angular.element('#permissionDeniedDialogOpener')
			return returnObject if not dialogOpenerElement or not dialogOpenerElement.click
			dialogOpenerElement.click()

		# others errors which leads to simple popup
		else
			alertFullMessage = 'Http response error (' + response.status + '). ' + (JSON.stringify(response.data) if response.data)
			console.log alertFullMessage

			return returnObject if not $rootScope.popup or not $rootScope.popup.show

			$rootScope.popup.show
				type: 'danger'
				text: 'Http error, see console log for details...'
				ttl: -1
				hideDuplicates: true

		return returnObject

])