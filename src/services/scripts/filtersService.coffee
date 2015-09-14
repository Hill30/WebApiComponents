hill30Module.service('filtersService', [
	'$location', ($location) ->

		instances = {}

		instance =

			initialize: (options = {}) ->
				self = this
				self.filters = options.filters || {}

			setFilter: (label, value, options = {}) ->
				self = this

				if angular.isArray(label) # so you can pass an array of label/value objects to setFilter method
					self.setFilter(item.label, item.value, item.options || options) for item in label
					return

				return self.unsetFilter(label, options) if value is '' or value is null

				if self.filters[label] isnt value
					self.filters[label] = value
					$location.search(label, value) if not options.ignoreRouting

				$location.search(label, null) if not options.ignoreRouting and options.cleanRouting

			unsetFilter: (label, options) ->
				self = this
				delete self.filters[label]
				$location.search(label, null) if not options.ignoreRouting
				true

			getFilters: (options = {}) ->
				self = this
				options.exclude = [options.exclude] if angular.isString(options.exclude)
				result = angular.copy(self.filters)
				if angular.isArray(options.exclude)
					for excludeItem in options.exclude
						delete result[excludeItem]
				if angular.isObject(options.include)
					angular.extend(result, options.include)
				result

			getFilter: (label) ->
				self = this
				self.filters[label]

		instanceToExtend =
			initialize: instance.initialize
			setFilter: instance.setFilter
			unsetFilter: instance.unsetFilter
			getFilters: instance.getFilters
			getFilter: instance.getFilter

		return {
		instance: (token = 'defaultInstance') ->
			result = instances[token]
			return result if angular.isObject(result)
			result = angular.extend({}, instanceToExtend)
			result.filters = {}
			result
		}
])