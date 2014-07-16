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

		setRouteParamsToCookie = (options) ->
			routeParams = $location.search()
			if options and options.exclude and options.exclude.length
				for param in options.exclude
					delete routeParams[param]
			setCookie(routeParamsCookieName, JSON.stringify(routeParams))

		getRouteParamsFromCookie = () ->
			return if not isCookieExists(routeParamsCookieName)
			params = JSON.parse(getCookie(routeParamsCookieName))
			for param in params
				param = param.toString() if Object.prototype.toString.call(param) is '[object Array]'
			$location.search params

		clearRouteParamsCookie = () ->
			return if not isCookieExists(routeParamsCookieName)
			setCookie(routeParamsCookieName, '')

		{
		setCookie: setCookie
		getCookie: getCookie
		isCookieExists: isCookieExists
		setRouteParamsCookieName: setRouteParamsCookieName
		setRouteParamsToCookie: setRouteParamsToCookie
		getRouteParamsFromCookie: getRouteParamsFromCookie
		clearRouteParamsCookie: clearRouteParamsCookie
		}
]
