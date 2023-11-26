--[[
	The text module contains common styles of text found throughout the project

	Text.Normal: A normal text label
	Text.Title: A title text label
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Table = require(ReplicatedStorage.Packages.TableUtil)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local FONT = "rbxasset://fonts/families/GothamSSm.json"

local defaultProps = {
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Text = "",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	FontFace = Font.new(FONT),
	TextScaled = true,
	BackgroundTransparency = 1,
	BackgroundColor3 = Color3.fromRGB(112, 24, 24),
	TextXAlignment = Enum.TextXAlignment.Center,
	AutomaticSize = Enum.AutomaticSize.None,
	[Children] = nil,
	LayoutOrder = 1,
}

--[=[
	Shallow merges two tables without modifying either.

	@param orig table -- Original table
	@param new table -- Result
	@return table
]=]
function Table.merge(orig, new)
	local result = table.clone(orig)
	for key, val in pairs(new) do
		result[key] = val
	end
	return result
end


type Text = typeof(defaultProps)

local function text(props: Text)
	return New("TextLabel")(Table.Merge(defaultProps, props))
end

return {
	Normal = text,
	Title = function(props: Text)
		return text(Table.Merge(props, {
			FontFace = Font.new(FONT, Enum.FontWeight.Bold),
			Text = if typeof(props.Text) == "string"
				then props.Text
				elseif props.Text then Computed(function(use)
					return tostring(props.Text)
				end)
				else "",
		}))
	end,
}
