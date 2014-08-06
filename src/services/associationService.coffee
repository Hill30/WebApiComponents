hill30Module.service('associationService', () ->

	checkArray = (array) ->
		array = [] if not array or not angular.isArray(array)

	addItem = (array, itemToAdd, token = 'id') ->
		checkArray array
		for item in array
			return if item[token] is itemToAdd[token]
		array.push itemToAdd

	removeItem = (array, itemToRemove, token = 'id') ->
		checkArray array
		for item, index in array
			if item[token] is itemToRemove[token]
				return array.splice(index, 1)

	filterList = (list1, list2) ->
		list1.filter (val1) ->
			for val2 in list2
				return false if val1 is val2
			return true

	getFilteredTokenLists = (objectList, tokenList, token = 'id') ->
		newTokenList = []
		originalTokenList = []
		newTokenList.push group[token] for group in objectList
		originalTokenList.push groupToken for groupToken in tokenList
		addedTokenList= filterList newTokenList, originalTokenList
		deletedTokenList = filterList originalTokenList, newTokenList
		return {
			addedList: addedTokenList
			deletedList: deletedTokenList
		}


	return {
		addItem: addItem
		removeItem: removeItem
		getFilteredTokenLists: getFilteredTokenLists
	}
)