hill30Module.service 'cookies', [
	->
		setCookie = (key, value, expire) ->
			return Cookies.set(key, value, { expires: expire });
		getCookie = (key) ->	
			return Cookies(key)
		{
			setCookie: setCookie,
			getCookie: getCookie
		}
]
