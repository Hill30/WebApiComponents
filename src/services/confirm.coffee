hill30Module.factory 'confirm', ['$modal', ($modal) ->

	confirmStatic = {}
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

	confirmStatic.setUiData = ($scope, data) ->
		$scope.uiData = {}
		$scope.uiData.title = data.title or confirmStatic.uiDataDefault.title
		$scope.uiData.text = data.text or confirmStatic.uiDataDefault.text
		$scope.uiData.cancel = data.cancelCaption or confirmStatic.uiDataDefault.cancel
		$scope.uiData.do = data.doCaption or confirmStatic.uiDataDefault.do
		$scope.level = if confirmStatic.levels.indexOf(data.level) isnt -1 then data.level else confirmStatic.defaultLevel

	confirmStatic.dismissDialog =  (modalInstance, reason) ->
		confirmStatic.modalInstance = null
		modalInstance.dismiss(reason)


	return {
		openDialog: (confirmObj) ->
			$modal.open
				template: confirmStatic.getTemplate

				controller: ($scope, $modalInstance) ->

					confirmStatic.setUiData $scope, confirmObj
					confirmStatic.modalInstance = $modalInstance

					$scope.$on '$routeChangeStart', () ->
						if confirmStatic.modalInstance
							confirmStatic.dismissDialog $modalInstance, 'cancel'

					$scope.do = () ->
						confirmStatic.dismissDialog $modalInstance, 'ok'
						if confirmObj.do and typeof confirmObj.do is 'function'
							confirmObj.do()

					$scope.cancel = () ->
						confirmStatic.dismissDialog $modalInstance, 'cancel'
						if confirmObj.cancel and typeof confirmObj.cancel is 'function'
							confirmObj.cancel()

				windowClass: ''

				backdrop: true

	}
]