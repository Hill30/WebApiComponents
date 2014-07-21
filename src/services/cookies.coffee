hill30Module.service 'cookies', ['$location'
	($location) ->
		routeParamsCookieName = 'routeParams'

		getPath = () ->
			absUrl = $location.$$absUrl
			host = $location.$$host
			port = $location.$$port.toString()
			path = absUrl.substr(absUrl.indexOf(host) + host.length)
			path = path.substr(port.length + 1) if port
			return '/' if not path
			path = ('/' + path) if path.indexOf('/') isnt 0
			path = path.substr(0, path.indexOf('#'))

		setCookie = (key, value, expire) ->
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
			options.path = getPath()
			Cookies.set(key, value, options)

		getCookie = (key) ->
			Cookies(key)

		isCookieExists = (token) ->
			return !!getCookie(token)

		isRouteParamsCookieExists = () ->
			return isCookieExists(routeParamsCookieName)

		setRouteParamsCookieName = (name) ->
			routeParamsCookieName = name

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

			setCookie(routeParamsCookieName, cookieValue)

		extractRouteParamsFromCookie = (options) ->
			return if not isCookieExists(routeParamsCookieName)
			cookieParams = JSON.parse(getCookie(routeParamsCookieName))
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
			return if not isCookieExists(routeParamsCookieName)
			setCookie(routeParamsCookieName, '')

		{
		setCookie: setCookie
		getCookie: getCookie
		isCookieExists: isCookieExists
		isRouteParamsCookieExists: isRouteParamsCookieExists
		setRouteParamsCookieName: setRouteParamsCookieName
		putRouteParamsToCookie: putRouteParamsToCookie
		extractRouteParamsFromCookie: extractRouteParamsFromCookie
		clearRouteParamsCookie: clearRouteParamsCookie
		}
]
