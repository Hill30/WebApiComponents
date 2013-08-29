angular.module('hill30.services', [])
	.service('filtersService',[
		'$log', '$rootScope', '$location', '$routeParams'
		(console, $rootScope, $location, $routeParams) ->

			filters = {}

			# exclude ngScroll default params
			filtersToExclude = ['offset', 'count']

			initFilters = (newFilters) ->
				filters = newFilters

			setFilter = (label, value, search = true) ->
				if filters[label] != value
					filters[label] = value
					$location.search getFilters(filtersToExclude) if search
				true

			unsetFilter = (label) ->
				delete filters[label]
				$location.search getFilters(filtersToExclude)
				true

			getFilters = (exclude) ->
				unless exclude && exclude.length > 0
					filters
				else
					angular.forEach filtersToExclude, (value) ->
						delete filters[value]
					console.log filters
					filters

			{
				initFilters
				setFilter
				unsetFilter
				getFilters
			}
	])