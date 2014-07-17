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

			setCookie(routeParamsCookieName, JSON.stringify(routeParams))

		extractRouteParamsFromCookie = (options) ->
			return if not isCookieExists(routeParamsCookieName)
			params = JSON.parse(getCookie(routeParamsCookieName))

			if options and options.replace and options.replace.length
				for token in options.replace
					$location.search(token, params[token]).replace() if params[token]
				return

			if options and options.exclude and options.exclude.length
				for token in options.exclude
					delete params[token]

			$location.search params

		clearRouteParamsCookie = () ->
			return if not isCookieExists(routeParamsCookieName)
			setCookie(routeParamsCookieName, '')

		{
		setCookie: setCookie
		getCookie: getCookie
		isCookieExists: isCookieExists
		setRouteParamsCookieName: setRouteParamsCookieName
		putRouteParamsToCookie: putRouteParamsToCookie
		extractRouteParamsFromCookie: extractRouteParamsFromCookie
		clearRouteParamsCookie: clearRouteParamsCookie
		}
]
