-- vstack fusion component

--[=[
	@class VStack
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children

return function(props)
	return New("Frame")({
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(0, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		BackgroundTransparency = 1,
		[Children] = {
			List = New("UIListLayout")({
				Parent = nil,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = props.HorizontalAlignment,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = props.VerticalAlignment,
				Padding = props.Padding,
			}),
			props[Children],
		},
	})
end
