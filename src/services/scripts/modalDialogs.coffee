hill30Module.factory 'modalDialogs', ['$modal', '$document', '$templateCache', '$filter',	($modal, $document, $templateCache, $filter) ->

	dialogList = []
	openedDialogList = []

	commonTemplateId = 'ModalDialogTemplateId'
	bodyElement = null
	modalBackdrop = null
	modalBackdropParent = null
	modalBackdropZIndex = null

	getTemplateId = (self) ->
		return self.id + if !self.inCache or !(self.inCache.all or self.inCache.body) then commonTemplateId else ''

	getTemplate = (self) ->
		return $templateCache.get(self.id) if self.inCache and self.inCache.all
		'
		<div>
			<div class="modal-header">
				<h4><span class="glyphicon {{uiData.iconClass}}"></span>
					{{uiData.title}}
				</h4>
			</div>
			<div class="modal-body">' + $templateCache.get(getTemplateId(self)) + '</div>
			<div class="modal-footer text-center">
				<span ng-repeat="action in uiData.actions">
					<button class="btn {{action.btnClass}}" ng-click="action.do()">
					<span class="glyphicon {{action.iconClass}}" ng-show="action.iconClass"></span>
						{{action.caption}}
					</button>
				</span>
			</div>
		</div>'


	configure = (configObj) ->
		self = this
		self.uiData = {}

		self.autoClose = if configObj.hasOwnProperty('autoClose') then configObj.autoClose else true
		self.onBeforeShow = configObj.onBeforeShow
		self.onBeforeClose = configObj.onBeforeClose

		self.uiData.data = {}
		for own key,val of configObj.data
			self.uiData.data[key] = val

		self.uiData.windowClass = configObj.windowClass or ''
		self.uiData.iconClass = configObj.iconClass or ''
		self.uiData.title = configObj.title or ''

		if configObj.actions and configObj.actions.length > 0
			self.uiData.actions = []
			for i in [0..configObj.actions.length - 1]
				action = configObj.actions[i]
				self.uiData.actions.push
					index: i
					btnClass: action.btnClass or ''
					iconClass: action.iconClass or ''
					caption: action.caption or 'Do' + if i > 0 then (i + 1) else ''
					do: () ->
						hideDialog(self)
						configObj.actions[this.index].do() if typeof configObj.actions[this.index].do is 'function'

		self.scope.uiData = self.uiData if self.scope
		self


	getDialogZIndex = (dlg) -> parseInt(dlg.modalWindowParent.children()[0].style.zIndex, 10)
	setDialogZIndex = (dlg, zIndex) -> dlg.modalWindowParent.children()[0].style.zIndex = zIndex

	showDialog = (self, options = {}) ->
		return if self.isDialogOpened # please close the dialog before open it again

		self.onBeforeShow() if not options.preventOnBeforeShow and typeof self.onBeforeShow is 'function'

		if openedDialogList.length > 0 # get z-index of the previous opened dialog
			zIndexPrev = 0
			for dlg in openedDialogList
				zIndexTemp = getDialogZIndex(dlg)
				zIndexPrev = zIndexTemp if zIndexTemp > zIndexPrev

		openedDialogList.push self
		self.isDialogOpened = true

		setDialogZIndex(self, zIndexPrev + 10) if zIndexPrev # increase z-index of current dialog if there is any opened one
		zIndex = getDialogZIndex(self)
		setModalBackdropZIndex(zIndex - 10 + 1) # move backdrop under the current dialog

		self.modalWindowParent.css({'display':'block'})

		if openedDialogList.length is 1 # show backdrop only for the 1st opening of some dialog
			bodyElement.addClass('modal-open')
			modalBackdropParent.css({'display':'block'})

	hideDialog = (self, options = {}) ->
		for dlg, i in openedDialogList
			if self is dlg
				openedDialogList.splice(i, 1)
				break

		self.onBeforeClose() if not options.preventOnBeforeClose and typeof self.onBeforeClose is 'function'

		self.isDialogOpened = false
		self.modalWindowParent.css({'display':'none'})

		if not openedDialogList.length
			setModalBackdropZIndex(modalBackdropZIndex) # move backdrop to the default layer
		else
			lastOpenedDialog = openedDialogList[openedDialogList.length - 1]
			zIndex = getDialogZIndex(lastOpenedDialog)
			setModalBackdropZIndex(zIndex - 10 + 1) # move backdrop under the last opened dialog

		if openedDialogList.length is 0 # hide back-drop when there are no dialogs
			modalBackdropParent.css({'display':'none'})
			bodyElement.removeClass('modal-open')

	hideAllDialogs = (force) ->
		i = openedDialogList.length - 1
		while dlg = openedDialogList[i--]
			if force or dlg.autoClose
				hideDialog(dlg)
				continue
			return false
		return true

	setModalBackdropZIndex = (zIndex) ->
		modalBackdrop = angular.element(document.querySelector('[modal-backdrop]'))
		if isNaN(zIndex = parseInt(zIndex, 10))
			modalBackdropZIndex = modalBackdropZIndex or parseInt(modalBackdrop.css('z-index'), 10) # todo dhilt : check it, probably this logic can be removed
			zIndex = modalBackdropZIndex
		modalBackdrop.css('z-index', zIndex)


	linking = (self) ->

		bodyElement = bodyElement or angular.element(document).find('body')

		# single backdrop
		setModalBackdropZIndex()
		if not modalBackdropParent
			modalBackdrop.wrap('<div id="modalBackDropParentId">')
			modalBackdropParent = modalBackdrop.parent()

			handleEscDown = (event) ->
				return if event.which isnt 27
				return unless hideAllDialogs()
				event.stopPropagation()
				event.preventDefault()

			$document.bind 'keydown', handleEscDown

		# multiple modalWindows

		modalWindows = angular.element(document.querySelectorAll('[modal-window]'))
		for modalWindow in modalWindows
			if modalWindow.parentElement.nodeName is "BODY"
				elt = angular.element(modalWindow)
				elt.wrap('<div id="' + getTemplateId(self) + '">')
				self.modalWindowParent = elt.parent()
				break

		if self.autoClose
			handleClick = (event) ->
				if event.target.hasAttribute('modal-window') or event.target.parentElement.hasAttribute('modal-window')
					return unless hideAllDialogs()
					event.stopPropagation()
					event.preventDefault()

			self.modalWindowParent.bind 'click', handleClick
			self.scope.$on '$destroy', () ->
				self.modalWindowParent.unbind 'click', handleClick


	openDialog = () ->
		self = this

		if self.isInitialized
			showDialog(self)
			return

		self.isInitialized = true

		$modal.open
			template: getTemplate(self)
			windowClass: self.uiData.windowClass
			backdrop: self.uiData.backdrop or 'static'
			keyboard: false
			controller: ($scope, $modalInstance) ->
				self.scope = $scope
				$scope.uiData = self.uiData
				$modalInstance.opened.then () ->
					linking(self)
					showDialog(self)


	instance = (options) ->
		if typeof options is 'string'
			options = id: options
		for dlg in dialogList
			return dlg if dlg.id is options.id
		newDlg =
			id: options.id
			inCache: options.inCache
			isInitialized: false
			isDialogOpened: false
			self: {}
			configure: configure
			openDialog: openDialog
			closeDialog: (options) ->
				hideDialog(newDlg, options)
		dialogList.push newDlg
		newDlg


	return {
		commonTemplateId: commonTemplateId
		instance: instance
		hideAllDialogs: hideAllDialogs
	}
]
