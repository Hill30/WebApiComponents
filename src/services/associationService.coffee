hill30Module.service('associationService', ['$log', (console) ->

	defaults =
		logging: true
		token: 'id'

	initialize = (options) ->
		defaults.logging = options.logging if options and options.hasOwnProperty('logging')
		defaults.token = options.token if options and options.hasOwnProperty('token')

	warning = (code) ->
		return if not defaults.logging
		text = "associationService undefined error"
		switch code
			when 1 then text = "associationService.addItem() 1st argument isn't an array"
			when 2 then text = "associationService.addItem() 2nd argument isn't an object"
			when 3 then text = "associationService.addItem() 2nd argument hasn't token-property"
			when 4 then text = "associationService.removeItem() 1st argument isn't an array"
			when 5 then text = "associationService.removeItem() 2nd argument isn't an object"
			when 6 then text = "associationService.removeItem() 2nd argument hasn't token-property"
			when 7 then text = "associationService.filterList() 1st argument isn't an array"
			when 8 then text = "associationService.filterList() 2nd argument isn't an array"
			when 9 then text = "associationService.getFilteredTokenLists() 1st argument isn't an array"
			when 10 then text = "associationService.getFilteredTokenLists() 2nd argument isn't an array"
		console text

	addItem = (array, itemToAdd, token = defaults.token) ->
		return warning(1) if not angular.isArray(array)
		return warning(2) if not angular.isObject(itemToAdd)
		return warning(3) if not itemToAdd.hasOwnProperty(token)

		for item in array
			return if item[token] is itemToAdd[token]
		array.push itemToAdd

	removeItem = (array, itemToRemove, token = defaults.token) ->
		return warning(4) if not angular.isArray(array)
		return warning(5) if not angular.isObject(itemToRemove)
		return warning(6) if not itemToRemove.hasOwnProperty(token)

		for item, index in array
			if item[token] is itemToRemove[token]
				return array.splice(index, 1)

	filterList = (list1, list2) ->
		return warning(7) if not angular.isArray(list1)
		return warning(8) if not angular.isArray(list2)

		list1.filter (val1) ->
			for val2 in list2
				return false if val1 is val2
			return true

	getFilteredTokenLists = (objectList, tokenList, token = defaults.token) ->
		return warning(9) if not angular.isArray(objectList)
		return warning(10) if not angular.isArray(tokenList)

		newTokenList = []
		originalTokenList = []
		newTokenList.push group[token] for group in objectList
		originalTokenList.push groupToken for groupToken in tokenList
		addedTokenList = filterList newTokenList, originalTokenList
		deletedTokenList = filterList originalTokenList, newTokenList
		return {
			addedList: addedTokenList
			deletedList: deletedTokenList
		}


	return {
		initialize: initialize
		addItem: addItem
		removeItem: removeItem
		getFilteredTokenLists: getFilteredTokenLists
	}
])