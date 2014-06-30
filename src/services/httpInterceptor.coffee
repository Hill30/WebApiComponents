hill30Module.factory('httpInterceptor', ["$q", "$rootScope", ($q, $rootScope) ->

	###response: (response) ->

		#$rootScope.$broadcast "success:#{response.status}", response

		response || $q.when(response)###

	responseError: (response) ->

		#$rootScope.$broadcast "error_#{response.status}", response

		returnObject = {}
		returnObject = $q.reject response

		if response.status isnt 403

			return returnObject if not (alertElement = angular.element('#httpErrorsBox'))

			alertFullMessage = 'Http response error (' + response.status + '). ' + (JSON.stringify(response.data) if response.data)
			console.log(alertFullMessage)

			alertShortMessage = 'Http error, see console log for details...'
			$rootScope.popup.show
				type: 'danger'
				text: alertShortMessage
				ttl: -1
				hideDuplicates: true

		else

			return returnObject if not(dialogOpenerElement = angular.element('#permissionDeniedDialogOpener'))

			dialogOpenerElement.click()

		returnObject

])