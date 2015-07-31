angular.module('ui.multiselect', [
	'multiselect.tpl.html'
])

	//from bootstrap-ui typeahead parser
	.factory('optionParser', ['$parse', function ($parse) {

		//                      00000111000000000000022200000000000000003333333333333330000000000044000
		var TYPEAHEAD_REGEXP = /^\s*(.*?)(?:\s+as\s+(.*?))?\s+for\s+(?:([\$\w][\$\w\d]*))\s+in\s+(.*)$/;

		return {
			parse: function (input) {

				var match = input.match(TYPEAHEAD_REGEXP), modelMapper, viewMapper, source;
				if (!match) {
					throw new Error(
							"Expected typeahead specification in form of '_modelValue_ (as _label_)? for _item_ in _collection_'" +
							" but got '" + input + "'.");
				}

				return {
					itemName: match[3],
					source: $parse(match[4]),
					viewMapper: $parse(match[2] || match[1]),
					modelMapper: $parse(match[1])
				};
			}
		};
	}])

	.directive('multiselect', ['$parse', '$document', '$compile', '$interpolate', 'optionParser',

		function ($parse, $document, $compile, $interpolate, optionParser) {
			return {
				restrict: 'E',
				require: 'ngModel',
				link: function (originalScope, element, attrs, modelCtrl) {

					var exp = attrs.options,
						parsedResult = optionParser.parse(exp),
						isMultiple = attrs.multiple && attrs.multiple !== 'false',
						required = false,
						scope = originalScope.$new(),
						changeHandler = attrs.change || angular.noop;

					scope.items = [];
					scope.header = 'Select';
					scope.multiple = isMultiple;
					scope.disabled = false;

					originalScope.$on('$destroy', function () {
						scope.$destroy();
					});

					var popUpEl = angular.element('<multiselect-popup></multiselect-popup>');

					//required validator
					if (attrs.required || attrs.ngRequired) {
						required = true;
					}
					attrs.$observe('required', function(newVal) {
						required = newVal;
					});

					//watch disabled state
					scope.$watch(function () {
						return $parse(attrs.disabled)(originalScope);
					}, function (newVal) {
						scope.disabled = newVal;
					});

					//watch single/multiple state for dynamically change single to multiple
					scope.$watch(function () {
						return $parse(attrs.multiple)(originalScope);
					}, function (newVal) {
						isMultiple = newVal || false;
					});

					//watch option changes for options that are populated dynamically
					scope.$watch(function () {
						return parsedResult.source(originalScope);
					}, function (newVal) {
						if (angular.isDefined(newVal))
							parseModel();
					}, true);

					//watch model change
					scope.$watch(function () {
						return modelCtrl.$modelValue;
					}, function (newVal, oldVal) {
						//when directive initialize, newVal usually undefined. Also, if model value already set in the controller
						//for preselected list then we need to mark checked in our scope item. But we don't want to do this every time
						//model changes. We need to do this only if it is done outside directive scope, from controller, for example.
						if (angular.isDefined(newVal)) {
							markChecked(newVal);
							scope.$eval(changeHandler);
						}
						getHeaderText();
						modelCtrl.$setValidity('required', scope.valid());
					}, true);

					function parseModel() {
						scope.items.length = 0;
						var model = parsedResult.source(originalScope);
						if(!angular.isDefined(model)) return;
						for (var i = 0; i < model.length; i++) {
							var local = {};
							local[parsedResult.itemName] = model[i];
							scope.items.push({
								label: parsedResult.viewMapper(local),
								model: model[i],
								checked: attrs.msRestoreCheck ? !!model[i][attrs.msRestoreCheck] : false
							});
						}
					}

					parseModel();

					element.append($compile(popUpEl)(scope));


					attrs.$observe('msText', function(newVal) { // (c) dhilt, 2015
						scope.text = newVal;
					});
					scope.noSearch = attrs.msSearch == 'false'; // (c) dhilt, 2015
					scope.msReset = attrs.msReset;  // (c) dhilt, 2015
					if(attrs.msOnSearch && typeof scope[attrs.msOnSearch] === 'function') {
						// on search event callback (c) dhilt, 2015
						scope.msOnSearchCallback = scope[attrs.msOnSearch];
					}


					function getHeaderText() {
						if (is_empty(modelCtrl.$modelValue)) return scope.header = attrs.msHeader || 'Select';

						if (isMultiple) {
							if (attrs.msSelected) {
								scope.header = $interpolate(attrs.msSelected)(scope);
							} else {
								scope.header = modelCtrl.$modelValue.length + ' ' + 'selected';
							}

						} else {
							var local = {};
							local[parsedResult.itemName] = modelCtrl.$modelValue;
							scope.header = parsedResult.viewMapper(local);
						}
					}

					function is_empty(obj) {
						if (!obj) return true;
						if (obj.length && obj.length > 0) return false;
						for (var prop in obj) if (obj[prop]) return false;
						return true;
					};

					scope.valid = function validModel() {
						if(!required) return true;
						var value = modelCtrl.$modelValue;
						return (angular.isArray(value) && value.length > 0) || (!angular.isArray(value) && value != null);
					};

					function selectSingle(item) {
						if (item.checked) {
							scope.uncheckAll();
						} else {
							scope.uncheckAll();
							item.checked = !item.checked;
						}
						setModelValue();
					}

					function selectMultiple(item) {
						item.checked = !item.checked;
						setModelValue();
					}

					function setModelValue() {
						var value;

						if (isMultiple) {
							value = [];
							angular.forEach(scope.items, function (item) {
								if (item.checked) value.push(item.model);
							})
						} else {
							angular.forEach(scope.items, function (item) {
								if (item.checked) {
									value = item.model;
									return false;
								}
							})
						}
						modelCtrl.$setViewValue(value);
					}

					function markChecked(newVal) {
						if (!angular.isArray(newVal)) {
							angular.forEach(scope.items, function (item) {
								if (angular.equals(item.model, newVal)) {
									item.checked = true;
									return false;
								}
							});
						} else {
							angular.forEach(scope.items, function (item) {
								item.checked = false;
								angular.forEach(newVal, function (i) {
									if (angular.equals(item.model, i)) {
										item.checked = true;
									}
								});
							});
						}
					}

					scope.checkAll = function () {
						if (!isMultiple) return;
						angular.forEach(scope.items, function (item) {
							item.checked = true;
						});
						setModelValue();
					};

					scope.uncheckAll = function () {
						angular.forEach(scope.items, function (item) {
							item.checked = false;
						});
						setModelValue();
					};

					scope.select = function (item) {
						if (isMultiple === false) {
							selectSingle(item);
							scope.closeSelect();
						} else {
							selectMultiple(item);
						}
					};

					// here and below (c) dhilt, 2015

					var programFocus = false;

					scope.$watch(function() { return element.attr('tabindex'); }, function () {
						scope.tabindex = element.attr('tabindex');
					});
					scope.tabindex = element.attr('tabindex');

					var handleKeyDown = function (event) {
						if(event.which === 13 || event.which === 32){ // enter, space
							if (scope.openSelect()) {
								event.stopPropagation();
								event.preventDefault();
							}
						}
						if(event.which === 9 || event.which === 27){ // tab, esc
							scope.closeSelect();
							scope.focusToggler();
						}
					};

					var handleClick = function (event) {
						scope.openSelect();
						event.stopPropagation();
						event.preventDefault();
					};

					scope.focusToggler = function(){
						programFocus = true;
						element.focus();
					};

					var handleFocus = function () {
						if (programFocus) {
							return programFocus = false;
						}
						scope.openSelect();
					};

					element.bind('keydown', handleKeyDown);
					element.bind('click', handleClick);
					element.bind('focus', handleFocus);

					scope.$on("$destroy", function () {
						element.unbind('keydown', handleKeyDown);
						element.unbind('click', handleClick);
						element.unbind('focus', handleFocus);
					});
				}
			};
		}])

	.directive('multiselectPopup', ['$document', '$filter', function ($document, $filter) {
		return {
			restrict: 'E',
			scope: false,
			replace: true,
			templateUrl: 'multiselect.tpl.html',
			link: function (scope, element, attrs) {

				scope.isVisible = false;

				scope.openSelect = function () {
					if (!element.hasClass('open')) {
						element.addClass('open');
						$document.bind('click', clickHandler);
						scope.focus();
						return true;
					}
				};
				scope.closeSelect = function () {
					if (element.hasClass('open')) {
						element.removeClass('open');
						$document.unbind('click', clickHandler);
						resetSelectionAndCounter();
						scope.focusToggler();
						return true;
					}
				};

				scope.toggleSelect = function () {
					if(!scope.closeSelect())
						scope.openSelect();
				};

				function clickHandler(event) {
					if (elementMatchesAnyInArray(event.target, element.find(event.target.tagName)))
						return;
					element.removeClass('open');
					$document.unbind('click', clickHandler);
					scope.$apply();
				}

				var searchElement = element.find('input')[0];
				var dropdownElement = searchElement.parentElement.parentElement;

				dropdownElement.tabIndex = scope.tabindex || 0;
				searchElement.tabIndex = scope.tabindex || 0;
				scope.$watch('tabindex', function () {
					dropdownElement.tabIndex = scope.tabindex;
					searchElement.tabIndex = scope.tabindex;
				});

				scope.focus = function focus(){
					if(scope.noSearch) {
						dropdownElement.focus();
					}
					searchElement.focus();
				};

				var elementMatchesAnyInArray = function (element, elementArray) {
					for (var i = 0; i < elementArray.length; i++)
						if (element == elementArray[i])
							return true;
					return false;
				};

				var current = -1;
				var itemsCounter = -1;
				var countItems = function () {
					if(itemsCounter >= 0) {
						return itemsCounter;
					}
					return itemsCounter = element.find('a').length - 2;
				};
				var getItem = function (position) {
					var elt = element.find('a')[position + 1];
					if(!elt) return;
					return angular.element(elt);
				};
				var toggleCurrentSelection = function() {
					if (current !== -1) {
						var item = getItem(current);
						if(!item) return;
						if(item.hasClass('selected'))
							item.removeClass('selected');
						else item.addClass('selected');
					}
				};
				var resetSelection = function() {
					if(current < 0) return;
					var elements = element.find('a');
					for(var i = elements.length - 1; i > 0; i--) {
						elements[i].className = elements[i].className.replace('selected', '');
					}
					current = -1;
				};
				var resetSelectionAndCounter = function() {
					resetSelection();
					itemsCounter = -1;
				};

				var handleKeyDown = function (event) {
					if(event.which === 38 || event.which === 40) { // up, down
						toggleCurrentSelection();
						if(event.which === 38 && --current < 0) current = countItems();
						if(event.which === 40 && ++current > countItems()) current = 0;
						toggleCurrentSelection();
					}
					else if (event.which === 13 || event.which === 32) { //enter, space
						var list = $filter('filter')(scope.items, scope.searchText);
						scope.select(list[current]);
					}
					else if (event.which === 9 || event.which === 27) { // tab, esc
						return resetSelection();
					}
					else return;
					event.stopPropagation();
					event.preventDefault();
				};

				scope.$watch('searchText.label', function(value) {
					if(scope.msOnSearchCallback) {
						scope.msOnSearchCallback(value);
					}
					resetSelectionAndCounter();
				});

				element.bind('keydown', handleKeyDown);

				scope.$on("$destroy", function () {
					element.unbind('keydown', handleKeyDown);
				});

				// dhilt : to be able to reset dropdown's selection and search input outside of the directive
				if(scope.msReset) {
					scope.$watch(scope.msReset, function (val) {
						if(angular.isDefined(val)) {
							scope.searchText = {};
							scope.uncheckAll();
						}
					});
				}
			}
		}
	}]);

angular.module('multiselect.tpl.html', [])

	.run(['$templateCache', function($templateCache) {
		$templateCache.put('multiselect.tpl.html',

				"<div class=\"btn-group btn-group-sm\">\n" +
				"  <a type=\"button\" class=\"btn btn-default dropdown-toggle\" ng-click=\"toggleSelect()\" ng-disabled=\"disabled\" ng-class=\"{'error': !valid()}\">\n" +
				"   <span class=\"btn-inn\" tooltip=\"{{text}}\" tooltip-append-to-body=\"true\"  tooltip-placement=\"top\">{{text}}<span class=\"caret\" ></span></span>\n" +
				"  </a>\n" +
				"  <ul class=\"dropdown-menu\">\n" +
				"    <li ng-hide=\"noSearch\" class=\"li-form-control\">\n" +
				"      <input class=\"form-control input-sm\" type=\"text\" ng-model=\"searchText.label\" autofocus=\"autofocus\" placeholder=\"Filter\" />\n" +
				"    </li>\n" +
				"    <li ng-repeat=\"i in items | filter:searchText\">\n" +
				"      <a ng-click=\"select(i); $event.stopPropagation();\">\n" +
				"        <span class=\"glyphicon\" ng-class=\"{'glyphicon-checkmark-2': i.checked, 'empty': !i.checked}\"></span> {{i.label}}</a>\n" +
				"    </li>\n" +
				"  </ul>\n" +
				"</div>");
	}]);