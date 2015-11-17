hill30Module.factory('httpInterceptor', ['$q', '$rootScope', '$injector' , ($q, $rootScope, $injector) ->

	getIgnoreErrorsParam = (response) ->
		return false if !response or !response.config
		if response.config.method is 'GET'
			container = response.config.params
		else if response.config.method is 'POST'
			container = response.config.data
		else return false
		return if container and container.hasOwnProperty('ignoreErrors') then container['ignoreErrors'] else false

	###response: (response) ->

		#$rootScope.$broadcast "success:#{response.status}", response

		response || $q.when(response)###

	responseError: (response) ->

		#$rootScope.$broadcast "error_#{response.status}", response

		returnObject = {}
		returnObject = $q.reject response

		# ignoreErrors: ignore any errors or just errors with specific statuses
		if ignoreErrors = getIgnoreErrorsParam(response)

			# if ignoreErrors is set to true then we need to ignore any error
			return returnObject if ignoreErrors is true or ignoreErrors is 'true'

			# let's try to parse ignoreErrors as array to get the list of statuses which have to be ignored
			ignoreErrors = [ignoreErrors] if not angular.isArray(ignoreErrors)
			for ignore in ignoreErrors
				return returnObject if response.status is ignore

		# 403 permission error which leads to permission dialog
		if response.status is 403
			return returnObject unless $rootScope.httpErrorsBox or $rootScope.httpErrorsBox.permissionDeniedDialog or $rootScope.httpErrorsBox.permissionDeniedDialog.openDialog
			$rootScope.httpErrorsBox.permissionDeniedDialog.openDialog()

		# others errors which leads to simple popup
		else
			alertFullMessage = 'Http response error (' + response.status + '). ' + (JSON.stringify(response.data) if response.data)
			console.log alertFullMessage
			
			if popup = $injector.get('popup')
				popup.show
					type: 'danger'
					text: 'Http error, see console log for details...'
					ttl: -1
					hideDuplicates: true

		return returnObject

])