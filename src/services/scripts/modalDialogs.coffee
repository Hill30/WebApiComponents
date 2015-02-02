hill30Module.factory 'modalDialogs', ['$modal', '$document', '$templateCache', 	($modal, $document, $templateCache) ->

	dialogList = []

	commonTemplateId = 'ModalDialogTemplateId'
	modalBackdrop = null
	modalBackdropParent = null
	modalBackdropZIndex = null

	getTemplate = (self) ->
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
		self.onBeforeClose = configObj.onBeforeClose

		self.uiData.data = {}
		for own key,val of configObj.data
			self.uiData.data[key] = val

		self.uiData.windowClass = configObj.windowClass or ''
		self.uiData.iconClass = configObj.iconClass or ''
		self.uiData.title = configObj.title or ''

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


	showDialog = (self) ->
		self.isDialogOpened = true
		modalBackdrop.css('z-index', modalBackdropZIndex)
		modalBackdropParent.show()
		self.modalWindowParent.show(100)


	hideDialog = (self) ->
		self.isDialogOpened = false
		modalBackdropParent.hide()
		self.modalWindowParent.hide(100)
		self.onBeforeClose() if typeof self.onBeforeClose is 'function'


	hideAllDialogs = (force) ->
		for dlg in dialogList
			continue unless dlg.isDialogOpened
			return if not force and not dlg.autoClose
			hideDialog(dlg)
			return true


	linking = (self) ->

		# single backdrop

		modalBackdrop = angular.element(document.querySelector('[modal-backdrop]'))
		modalBackdropZIndex = modalBackdropZIndex or parseInt(modalBackdrop.css('z-index'), 10)

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


	instance = (id) ->
		for dlg in dialogList
			return dlg if dlg.id is id
		newDlg =
			id: id
			isInitialized: false
			isDialogOpened: false
			self: {}
			configure: configure
			openDialog: openDialog
		dialogList.push newDlg
		newDlg


	return {
		commonTemplateId: commonTemplateId
		instance: instance
		hideAllDialogs: hideAllDialogs
	}
]