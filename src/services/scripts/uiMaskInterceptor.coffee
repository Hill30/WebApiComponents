hill30Module.service 'uiMaskInterceptor', () ->

	data =
		type: null
		event: null
		newSections: null
		oldSections: null
		oldCaretPosition: null
		maskPlaceholder: null

	sectionsInit =
		date: (value) ->
			value.split("/")
		time: (value) ->
			sections = value.split(":")
			if sections.length is 2
				tmp = sections[1].split(" ")
				sections[1] = tmp[0]
				sections[2] = tmp[1]
			sections

	initialize = (type, event, value, oldValue, oldCaretPosition, maskPlaceholder) ->
		data.event = event
		data.newSections = sectionsInit[type](value)
		data.oldSections = sectionsInit[type](oldValue)
		data.oldCaretPosition = oldCaretPosition
		data.maskPlaceholder = maskPlaceholder

	parseAmPmSection = (secPos) ->
		if data.newSections.length - 1 >= secPos && data.newSections[secPos]
			val = data.newSections[secPos][0]
		if secPos > 0 and (length = data.newSections[secPos - 1].length)
			preVal = data.newSections[secPos - 1][length - 1];
		return "am" if val is "a" or preVal is "a"
		return "pm" if val is "p" or preVal is "p"
		return "xm"

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
		type = "date" if maskPlaceholder is "mm/dd/yyyy"
		type = "time" if maskPlaceholder is "hh:mm xm"
		return false if not type or not oldValue or value is maskPlaceholder
		initialize type, event, value, oldValue, oldCaretPosition, maskPlaceholder
		if type is "date"
			return "" + parseDigitalSection(0, "mm", 12) + "/" + parseDigitalSection(1, "dd", 31) + "/" + parseDigitalSection(2, "yyyy", 2999)
		if type is "time"
			return "" + parseDigitalSection(0, "hh", 12) + ":" + parseDigitalSection(1, "mm", 59) + " " + parseAmPmSection(2)

	return {
		unmaskValue: unmaskValue
	}
