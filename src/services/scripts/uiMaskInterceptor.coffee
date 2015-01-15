hill30Module.service 'uiMaskInterceptor', () ->

	data =
		event: null
		newSections: null
		oldSections: null
		oldCaretPosition: null
		maskPlaceholder: null

	init = (event, value, oldValue, oldCaretPosition, maskPlaceholder) ->
		data.event = event
		data.newSections = value.split("/")
		data.oldSections = oldValue.split("/")
		data.oldCaretPosition = oldCaretPosition
		data.maskPlaceholder = maskPlaceholder

	parseDigitalSection = (secPos, mask, absMax) ->
		return mask if data.newSections.length - 1 < secPos
		val = data.newSections[secPos].replace(/[^\d]/g, "")
		max = parseInt(absMax.toString().substr(0, 1), 10)
		digits = mask.length
		if val.length is digits + 1
			if data.newSections.length > secPos and (data.oldCaretPosition is secPos + digits * (secPos + 1))
				data.newSections[secPos + 1] = val[digits] + data.newSections[secPos + 1]
			val = val.substr(0, digits)
		zero = data.newSections[secPos][0] is "0"
		val = parseInt(val, 10)
		if isNaN(val) or val < 0 or val > absMax
			data.newSections[secPos + 2] = "" if secPos < 1
			data.newSections[secPos + 1] = "" if secPos < 2
			return mask
		return "0" + val if (zero and val > 0) or (val > max and val < 10)
		return val + mask[0]  if val <= max
		return val

	unmaskValue = (event, value, oldValue, oldCaretPosition, maskPlaceholder) ->
		return false if maskPlaceholder isnt "mm/dd/yyyy" or not oldValue or value is maskPlaceholder
		init event, value, oldValue, oldCaretPosition, maskPlaceholder
		return "" + parseDigitalSection(0, "mm", 12) + "/" + parseDigitalSection(1, "dd", 31) + "/" + parseDigitalSection(2, "yyyy", 2999)


	return {
		unmaskValue: unmaskValue
	}
