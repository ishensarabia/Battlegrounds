--[=[
	@class Button
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local Spring = Fusion.Spring
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value

return function(props)
	local size = Value(UDim2.fromScale(1, 1))

	return New("TextButton")({
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(0, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Visible = props.Visible,
		[OnEvent("MouseButton1Down")] = function()
			size:set(UDim2.fromScale(0.9, 0.9))
		end,
		[OnEvent("MouseButton1Up")] = function()
			size:set(UDim2.fromScale(1.1, 1.1))
		end,
		[OnEvent("MouseEnter")] = function()
			size:set(UDim2.fromScale(1.1, 1.1))
		end,
		[OnEvent("MouseLeave")] = function()
			size:set(UDim2.fromScale(1, 1))
		end,
		[OnEvent("Activated")] = props.OnClick,
		[Children] = {
			New("Frame")({
				Size = Spring(size, 40),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = props.BackgroundTransparency,
				BackgroundColor3 = props.BackgroundColor3,
				[Children] = props[Children],
			}),
		},
	})
end
