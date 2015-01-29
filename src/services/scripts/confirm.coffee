hill30Module.factory 'confirm', ['$modal', '$document', ($modal, $document) ->

	confirmStatic = {}
	confirmStatic.isInitialized = false
	confirmStatic.isDialogOpened = false

	confirmStatic.uiDataDefault =
		title: "Confirmation"
		text: "Are you sure?"
		doCaption: "Ok"
		cancelCaption: "Cancel"
		windowClass: ''
		doLevel: 'default'
		cancelLevel: 'default'


	confirmStatic.getTemplate = () ->
		'
		<div class="confirmBox">
			<div class="modal-header">
				<h4><span class="glyphicon glyphicon-checkmark"></span>
					{{uiData.title}}
				</h4>
			</div>

			<div class="modal-body text-center" ng-show="uiData.text">
				{{uiData.text}}
			</div>

			<div class="modal-footer text-center">
				<button class="btn btn-{{uiData.cancelLevel}}" ng-click="uiData.cancel()">{{uiData.cancelCaption}}</button>
				<button class="btn btn-{{uiData.doLevel}}" ng-click="uiData.do()">
					<span class="glyphicon glyphicon-remove-2" ng-show="uiData.doLevel == \'danger\'"></span>
					{{uiData.doCaption}}</button>
			</div>
		</div>'


	confirmStatic.configure = (data) ->
		self = confirmStatic
		self.uiData = {}
		self.uiData.windowClass = data.windowClass or self.uiDataDefault.windowClass
		self.uiData.doLevel = data.doLevel or self.uiDataDefault.doLevel
		self.uiData.cancelLevel = data.cancelLevel or self.uiDataDefault.cancelLevel
		self.uiData.title = data.title or self.uiDataDefault.title
		self.uiData.text = data.text or self.uiDataDefault.text
		self.uiData.doCaption = data.doCaption or self.uiDataDefault.doCaption
		self.uiData.cancelCaption = data.cancelCaption or self.uiDataDefault.cancelCaption
		self.uiData['do'] = () ->
			self.hideDialog()
			data['do']() if data['do'] && typeof data['do']  is 'function' 
		self.uiData['cancel'] = () ->
			self.hideDialog()
			data['cancel']() if data['cancel'] && typeof data['cancel']  is 'function'
		confirmStatic.scope.uiData = confirmStatic.uiData if confirmStatic.scope


	confirmStatic.linking = () ->
		self = confirmStatic
		
		modalBackdrop = angular.element('[modal-backdrop]')
		modalBackdrop.wrap('<div>')
		self.modalBackdrop = modalBackdrop.parent()
		modalWindow = angular.element('[modal-window]')
		modalWindow.wrap('<div>')
		self.modalWindow = modalWindow.parent()

		handleClick = (event) ->
			if event.target.hasAttribute('modal-window') or event.target.parentElement.hasAttribute('modal-window')
				self.hideDialog()
				event.stopPropagation()
				event.preventDefault()
		handleEscDown = (event) ->
			return if not confirmStatic.isDialogOpened or event.which isnt 27
			self.hideDialog();
			event.stopPropagation();
			event.preventDefault();

		self.modalWindow.bind 'click', handleClick
		$document.bind 'keydown', handleEscDown
		self.scope.$on '$destroy', () ->
			self.modalWindow.unbind 'click', handleClick
			$document.unbind 'keydown', handleEscDown
		self.scope.$on '$routeChangeStart', self.hideDialog
		
		confirmStatic.isDialogOpened = true


	confirmStatic.showDialog = () ->
		confirmStatic.isDialogOpened = true
		confirmStatic.modalBackdrop.show()
		confirmStatic.modalWindow.show()

	confirmStatic.hideDialog = () ->
		confirmStatic.isDialogOpened = false
		confirmStatic.modalBackdrop.hide()
		confirmStatic.modalWindow.hide(200)


	return {
		openDialog: (confirmObj) ->

			confirmStatic.configure(confirmObj)
			if confirmStatic.isInitialized
				confirmStatic.showDialog()
				return

			confirmStatic.isInitialized = true

			$modal.open
				template: confirmStatic.getTemplate
				windowClass: confirmStatic.uiData.windowClass
				backdrop: 'static'
				keyboard: false
				controller: ($scope, $modalInstance) ->
					confirmStatic.scope = $scope
					$scope.uiData = confirmStatic.uiData
					$modalInstance.opened.then confirmStatic.linking

	}
]