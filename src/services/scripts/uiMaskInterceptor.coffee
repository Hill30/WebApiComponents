hill30Module.service 'uiMaskInterceptor', () ->

	result = {}

	data =
		type: null
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

	initialize = (type, value, oldValue, oldCaretPosition, maskPlaceholder) ->
		data.newSections = sectionsInit[type](value)
		data.oldSections = sectionsInit[type](oldValue)
		data.oldCaretPosition = oldCaretPosition
		data.maskPlaceholder = maskPlaceholder

	parseCivilianSection = (secPos) ->
		if data.newSections.length - 1 >= secPos && data.newSections[secPos]
			val = data.newSections[secPos][0]
		if secPos > 0 and data.newSections[secPos - 1] and (length = data.newSections[secPos - 1].length)
			preVal = data.newSections[secPos - 1][length - 1];
		return "am" if preVal is "a"
		return "pm" if preVal is "p"
		return "am" if val is "a"
		return "pm" if val is "p"
		return "xx"

	parseDigitalSection = (secPos, mask, absMax) ->
		return mask if data.newSections.length - 1 < secPos
		val = data.newSections[secPos].replace(/[^\d]/g, "")
		max = parseInt(absMax.toString().substr(0, 1), 10)
		digits = mask.length
		if val.length is digits + 1
			if data.newSections.length > secPos and (data.oldCaretPosition is secPos + digits * (secPos + 1))
				data.newSections[secPos + 1] = val[digits] + data.newSections[secPos + 1]
			val = val.substr(0, digits)
		zero = data.newSections[secPos][0] is "0" and val.length and val.length > 1
		val = parseInt(val, 10)
		if isNaN(val) or val < 0 or val > absMax
			data.newSections[secPos + 2] = "" if secPos < 1
			data.newSections[secPos + 1] = "" if secPos < 2
			return mask
		return "0" + val if (zero and val >= 0) or (val > max and val < 10)
		return val + mask[0]  if val <= max
		return val

	unmaskValue = (value, oldValue, oldCaretPosition, maskPlaceholder) ->
		type = "date" if maskPlaceholder is "mm/dd/yyyy"
		type = "time" if maskPlaceholder is "hh:mm xx"
		return false if not type or not oldValue or value is maskPlaceholder
		initialize type, value, oldValue, oldCaretPosition, maskPlaceholder
		if type is "date"
			result.value = "" + parseDigitalSection(0, "mm", 12) + "/" + parseDigitalSection(1, "dd", 31) + "/" + parseDigitalSection(2, "yyyy", 2999)
		if type is "time"
			result.value = "" + parseDigitalSection(0, "hh", 12) + ":" + parseDigitalSection(1, "mm", 59) + " " + parseCivilianSection(2)
		result

	return {
		unmaskValue: unmaskValue
	}
