hill30Module.factory 'modalDialogs', ['$modal', '$document', '$templateCache', '$filter',	($modal, $document, $templateCache, $filter) ->

	dialogList = []
	openedDialogList = []

	commonTemplateId = 'ModalDialogTemplateId'
	bodyElement = null
	modalBackdrop = null
	modalBackdropParent = null
	modalBackdropZIndex = null

	getTemplate = (self) ->
		return $templateCache.get(self.id) if self.isPath
		'
		<div>
			<div class="modal-header">
				<h4><span class="glyphicon {{uiData.iconClass}}"></span>
					{{uiData.title}}
				</h4>
			</div>
			<div class="modal-body">' + $templateCache.get(self.id + commonTemplateId) + '</div>
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


	showDialog = (self, options = {}) ->
		openedDialogList.push self

		self.onBeforeShow() if not options.preventOnBeforeShow and typeof self.onBeforeShow is 'function'

		self.isDialogOpened = true
		zIndex = self.modalWindowParent.children()[0].style.zIndex # z-index of showing dialog
		self.modalWindowParent.show(100)
		setModalBackdropZIndex(zIndex - 10 + 1) # move backdrop under the current dialog

		if openedDialogList.length is 1 # show back-drop if there is one (first) dialog
			bodyElement.addClass('modal-open')
			modalBackdropParent.show()

	hideDialog = (self, options = {}) ->
		for dlg, i in openedDialogList
			if self is dlg
				openedDialogList.splice(i, 1)
				break

		self.onBeforeClose() if not options.preventOnBeforeClose and typeof self.onBeforeClose is 'function'

		self.isDialogOpened = false
		self.modalWindowParent.hide(100)

		if not openedDialogList.length
			setModalBackdropZIndex(modalBackdropZIndex) # move backdrop to the default layer
		else
			lastOpenedDialog = openedDialogList[openedDialogList.length - 1]
			zIndex = lastOpenedDialog.modalWindowParent.children()[0].style.zIndex
			setModalBackdropZIndex(zIndex - 10 + 1) # move backdrop under the last opened dialog

		if openedDialogList.length is 0 # hide back-drop when there are no dialogs
			modalBackdropParent.hide()
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
				elt.wrap('<div id="' + self.id + commonTemplateId + '">')
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


	instance = (id, isPath) ->
		for dlg in dialogList
			return dlg if dlg.id is id
		newDlg =
			id: id
			isPath: isPath
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