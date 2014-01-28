hill30Module.service 'cookies', [
	->
		setCookie = (key, value, expire) ->
			# Generate expire date (now + year) 
			d = new Date();
			month = d.getMonth() + 1;
			day = d.getDate();
			if day < 10
				day = '0' + day
			if month < 10
				month = '0' + month
			expireDate = new Date((d.getFullYear() + 1), month, day)

			if expire == undefined
				expire = expireDate

			Cookies.set(key, value, { expires: expire })

		getCookie = (key) ->	
			Cookies(key)
		{
			setCookie: setCookie,
			getCookie: getCookie
		}
]
