local FormatText = {}

function FormatText.To_comma_value(n)
	n = tostring(n)
	return n:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function FormatText.Remove_Spaces_And_Dashes(string)
	return string:gsub("%s+", ""):gsub("-", "")
end

return FormatText
