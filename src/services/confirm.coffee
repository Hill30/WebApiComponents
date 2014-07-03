hill30Module.factory 'confirm', ['$modal', ($modal) ->

	confirmStatic = {}
	confirmStatic.isInitialized = false
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

		self.modalWindow.bind 'click', (event) ->
			self.hideDialog()
			event.stopPropagation()
			event.preventDefault()

		self.scope.$on '$routeChangeStart', self.hideDialog


	confirmStatic.showDialog = () ->
		confirmStatic.modalBackdrop.show()
		confirmStatic.modalWindow.show()

	confirmStatic.hideDialog = () ->
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
	}
]