hill30Module.factory 'confirmation', [
	'modalDialogs', '$templateCache', '$timeout'
	(modalDialogs, $templateCache, $timeout) ->

		dialogInstanceId = 'confirm'
		instance = {}

		bodyTemplate =
			'{{ uiData.data.text }}'

		$templateCache.put(dialogInstanceId + modalDialogs.commonTemplateId, bodyTemplate)

		configure = (options) ->

			configObject =
				title: options.title or 'Confirmation'
				windowClass: options.windowClass or 'modal-valign-middle modal-confirm'
				iconClass: options.iconClass or 'glyphicon-checkmark'
				onBeforeShow: () ->
					$timeout ->
						if found = instance.modalWindowParent.find('.btn-primary')
							found[0].focus()
					75
				data:
					text: options.text or 'Are you sure?'
				actions: [
					caption: options.cancelCaption or 'Cancel'
					btnClass: options.cancelBtnClass or 'btn-primary'
					iconClass: options.cancelIconClass
					do: options.cancelAction
				,
					caption: options.confirmCaption or 'Confirm'
					btnClass: options.confirmBtnClass or 'btn-default'
					iconClass: options.cancelIconClass
					do: options.confirmAction
				]

			instance = modalDialogs.instance(dialogInstanceId)
			instance.configure(configObject)

		return {
			configure: configure
		}
]