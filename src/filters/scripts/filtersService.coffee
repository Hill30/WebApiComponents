hill30Module
	.service('filtersService',[
		'$log', '$rootScope', '$location'
		(console, $rootScope, $location) ->

			filters = {}

			# exclude ngScroll default params
			filtersToExclude = ['offset', 'count']

			initFilters = (newFilters) ->
				filters = newFilters

			setFilter = (label, value, search = true) ->
				if filters[label] != value
					filters[label] = value
					$location.search(label, value) if search
				$location.search(label, null) if not search
				true

			unsetFilter = (label) ->
				delete filters[label]
				$location.search(label, null)
				true

			getFilters = (exclude) ->
				unless exclude && exclude.length > 0
					filters
				else
					angular.forEach filtersToExclude, (value) ->
						delete filters[value]
					filters

			getFilter = (label) ->
				filters[label]

			{
				initFilters
				setFilter
				unsetFilter
				getFilters
				getFilter
			}
	])