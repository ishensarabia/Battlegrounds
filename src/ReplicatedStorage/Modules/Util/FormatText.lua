local FormatText = {}

function FormatText.To_comma_value(n)
	n = tostring(n)
	return n:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

return FormatText
