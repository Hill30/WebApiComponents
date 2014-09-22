hill30Module.service 'cookies', ['$location'
	($location) ->
		routeParamsCookiePrefix = 'routeParams'

		getRouteParamsCookieName = () ->
			absUrl = $location.$$absUrl
			host = $location.$$host
			port = $location.$$port.toString()
			path = absUrl.substr(absUrl.indexOf(host) + host.length)
			path = path.substr(port.length + 1) if path.indexOf(':' + port) is 0
			return '/' if not path
			path = ('/' + path) if path.indexOf('/') isnt 0
			path = path.substr(0, path.indexOf('#'))
			return (routeParamsCookiePrefix + path.replace(/\//g, '_'))

		setCookie = (name, value, expire) ->
			options = {}
			if expire is undefined
				# Generate expire date (now + year)
				d = new Date();
				month = d.getMonth() + 1;
				day = d.getDate();
				day = '0' + day if day < 10
				month = '0' + month if month < 10
				expire = new Date((d.getFullYear() + 1), month, day)
			options.expires = expire
			Cookies.set(name, value, options)

		getCookie = (key) ->
			Cookies(key)

		isCookieExists = (token) ->
			return !!getCookie(token)

		isRouteParamsCookieExists = () ->
			return isCookieExists(getRouteParamsCookieName())

		setRouteParamsCookiePrefix = (prefix) ->
			routeParamsCookiePrefix = prefix

		putRouteParamsToCookie = (options) ->
			routeParams = $location.search()

			if options and options.include and options.include.length
				newRouteParams = {}
				for token in options.include
					newRouteParams[token] = routeParams[token] if routeParams[token]
				routeParams = newRouteParams

			if options and options.exclude and options.exclude.length
				for token in options.exclude
					delete routeParams[token]

			cookieValue = JSON.stringify(routeParams)
			return clearRouteParamsCookie() if cookieValue is '{}'

			setCookie(getRouteParamsCookieName(), cookieValue)

		extractRouteParamsFromCookie = (options) ->
			return if not isRouteParamsCookieExists()
			cookieParams = JSON.parse(getCookie(getRouteParamsCookieName()))
			routeParams = $location.search()

			if options and options.replace and options.replace.length
				for token in options.replace
					if routeParams[token] and cookieParams[token]
						$location.search(token, cookieParams[token]).replace()
					else if routeParams[token] and not cookieParams[token]
						$location.search(token, null).replace()
					else if not routeParams[token] and cookieParams[token]
						$location.search(token, cookieParams[token])
				return

			if options and options.exclude and options.exclude.length
				for token in options.exclude
					delete cookieParams[token]

			$location.search cookieParams

		clearRouteParamsCookie = () ->
			return if not isCookieExists(routeParamsCookiePrefix)
			setCookie(routeParamsCookiePrefix, '')

		{
		setCookie: setCookie
		getCookie: getCookie
		isCookieExists: isCookieExists
		isRouteParamsCookieExists: isRouteParamsCookieExists
		setRouteParamsCookieName: setRouteParamsCookiePrefix
		putRouteParamsToCookie: putRouteParamsToCookie
		extractRouteParamsFromCookie: extractRouteParamsFromCookie
		clearRouteParamsCookie: clearRouteParamsCookie
		}
]
