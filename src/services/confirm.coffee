hill30Module.factory 'confirm', ['$modal', '$document', ($modal, $document) ->

	confirmStatic = {}
	confirmStatic.isInitialized = false
	confirmStatic.isDialogOpened = false
	confirmStatic.levels = ['default', 'danger']
	confirmStatic.defaultLevel = 'default'

	confirmStatic.uiDataDefault =
		title: "Confirmation"
		text: "Are you sure?"
		do: "Ok"
		cancel: "Cancel"


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
				<button class="btn btn-default" ng-click="cancel()">{{uiData.cancel}}</button>
				<button class="btn btn-{{level}}" ng-click="do()">
					<span class="glyphicon glyphicon-remove-2" ng-show="level == \'danger\'"></span>
					{{uiData.do}}</button>
			</div>
		</div>'


	confirmStatic.configure = (data) ->
		self = confirmStatic
		scope = self.scope
		scope.uiData = {}
		scope.uiData.title = data.title or self.uiDataDefault.title
		scope.uiData.text = data.text or self.uiDataDefault.text
		scope.level = if self.levels.indexOf(data.level) isnt -1 then data.level else self.defaultLevel
		scope.uiData['do'] = data.doCaption or self.uiDataDefault['do']
		scope.uiData['cancel'] = data.cancelCaption or self.uiDataDefault['cancel']
		scope['do'] = () -> 
			self.hideDialog()
			data['do']() if data['do'] && typeof data['do']  is 'function' 
		scope['cancel'] = () -> 
			self.hideDialog()
			data['cancel']() if data['cancel'] && typeof data['cancel']  is 'function'


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

			if confirmStatic.isInitialized
				confirmStatic.configure(confirmObj)
				confirmStatic.showDialog()
				return

			confirmStatic.isInitialized = true

			$modal.open
				template: confirmStatic.getTemplate

				controller: ($scope, $modalInstance) ->
					confirmStatic.scope = $scope
					confirmStatic.configure(confirmObj)
					$modalInstance.opened.then confirmStatic.linking

				windowClass: ''

				backdrop: 'static'

				keyboard: false
	}
]