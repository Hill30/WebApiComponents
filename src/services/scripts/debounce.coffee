hill30Module.factory 'debounce', ['$timeout', '$q', ($timeout, $q) ->
	return (func, wait, immediate) ->
		timeout = null
		deferred = $q.defer()
		return () ->
			context = this
			args = arguments
			later = () ->
				timeout = null
				if(!immediate)
					deferred.resolve(func.apply(context, args))
					deferred = $q.defer()

			callNow = immediate && !timeout;
			if ( timeout )
				$timeout.cancel(timeout)

			timeout = $timeout(later, wait)

			if (callNow)
				deferred.resolve(func.apply(context, args))
				deferred = $q.defer()

			return deferred.promise;
]