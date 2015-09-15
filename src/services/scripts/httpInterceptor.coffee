hill30Module.factory('httpInterceptor', ['$q', '$rootScope', '$injector' , ($q, $rootScope, $injector) ->

	###response: (response) ->

		#$rootScope.$broadcast "success:#{response.status}", response

		response || $q.when(response)###

	responseError: (response) ->

		#$rootScope.$broadcast "error_#{response.status}", response

		returnObject = {}
		returnObject = $q.reject response

		# error statuses which has to be ignored
		if response.config and response.config.params and response.config.params.hasOwnProperty('ignoreErrors')
			# if ignoreErrors has a value then let's try to get the list of statuses which have to be ignored
			if ignoreList = response.config.params.ignoreErrors
				if not angular.isArray(ignoreList)
					ignoreList = [ignoreList]
				for ignore in ignoreList
					if response.status is ignore
						return returnObject
			# if ignoreErrors has no value then we need to ignore any error
			else return returnObject

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