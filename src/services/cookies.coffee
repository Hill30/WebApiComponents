hill30Module.service 'cookies', ['$location'
	($location) ->
		routeParamsCookieName = 'routeParams'

		setCookie = (key, value, expire) ->
			# Generate expire date (now + year)
			d = new Date();
			month = d.getMonth() + 1;
			day = d.getDate();
			day = '0' + day if day < 10
			month = '0' + month if month < 10
			expireDate = new Date((d.getFullYear() + 1), month, day)
			expire = expireDate if expire is undefined
			Cookies.set(key, value, { expires: expire })

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
					else if cookieParams[token]
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
