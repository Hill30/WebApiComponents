###

popup service (c) dhilt, 2015

example:
popup.show({ type: 'info', text: 'Are you ready for Christmas?', isFunctional: true, doNotCloseAfterAction: true, doCaption: 'Sure', ttl:2500, hideDuplicates: true, do: () -> alert('Good!') })

options:
type -- success (green), info (blue), warning (yellow), danger (red)
text -- popup message
ttl -- the popup will be closed automatically after this time (ms) expires (default value is present); "-1" for not auto disappear
hideDuplicates -- prevents rising of duplicating popups if set
isFunctional -- a button which provides an action
do -- an action (callback function) of functional popup
doCaption -- caption of action button (default value is present)
doNotCloseAfterAction -- if not set the popup will be closed right after action button is pressed

###


hill30Module.service('popup', 
['$rootScope', '$compile', '$timeout', 
($rootScope, $compile, $timeout) ->

	isInitialized = false
	scope = null
	list = []
	idLast = 0
	ttlDefault = 1500
	doCaptionDefault = 'Ok'


	getTemplate = () ->
		'
		<div class="popupBox" id="webApiComponents.services.popup">
			<div ng-repeat="item in list">
				<alert type="{{item.type}}" close="close(item)">
					{{item.text}}
					<div ng-show="item.isFunctional" class="button">
						<a class="btn btn-default btn-sm" href="" ng-click="item.doAction()">{{item.doCaption}}</a>
					</div>
				</alert>
			</div>
		</div>'
			

	init = () ->
		scope = $rootScope.$new()
		scope.list = list
		scope.close = close

		body = angular.element(document).find('body')
		popupElement = angular.element getTemplate()
		linkFn = $compile(popupElement)(scope)
		body.append(linkFn)
		isInitialized = true


	isEqual = (p1, p2) ->
		return true if not p1 or not p2
		return if (p1.type or p2.type) and p1.type isnt p2.type
		return if (p1.text or p2.text) and p1.text isnt p2.text
		if p1.isFunctional or p2.isFunctional
			return if not p2.isFunctional or not p1.isFunctional
			return if p1.doCaption isnt p2.doCaption
		return true


	close = (popupObj) ->
		for item, index in list
			if item.id is popupObj.id
				list.splice index, 1
				break


	show = (popupObj) ->
		idLast++
		popupObj.id = idLast

		ttl = parseInt popupObj.ttl, 10
		if ttl isnt -1
			ttl = if ttl > 0 then ttl else ttlDefault
			$timeout(() ->
				close popupObj
			, ttl)

		if popupObj.isFunctional
			if not popupObj.do or typeof(popupObj.do) isnt 'function'
				popupObj.isFunctional = false
			else
				popupObj.doCaption = popupObj.doCaption or doCaptionDefault
				popupObj.doAction = () ->
					close popupObj unless popupObj.doNotCloseAfterAction
					popupObj.do.call(popupObj)

		if popupObj.hideDuplicates
			for item, index in list
				if isEqual item, popupObj
					close item

		list.push popupObj
		scope.$apply() unless scope.$$phase

		() -> close(popupObj)


	return {
		show: (options) ->
			init() unless isInitialized
			show options
	}
])