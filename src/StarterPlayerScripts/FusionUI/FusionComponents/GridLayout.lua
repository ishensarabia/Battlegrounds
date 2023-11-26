-- GridLayout fusion component

--[=[
	@class GridLayout
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
			Grid = New("UIGridLayout")({
				CellPadding = props.CellPadding,
				CellSize = props.CellSize,
				FillDirectionMaxCells = props.FillDirectionMaxCells,
				FillDirection = props.FillDirection,
				HorizontalAlignment = props.HorizontalAlignment,
				SortOrder = props.SortOrder,
				StartCorner = props.StartCorner,
				VerticalAlignment = props.VerticalAlignment,
				[Children] = props.AspectRatio and {
					AspectRatioConstraint = New("UIAspectRatioConstraint")({
						AspectRatio = props.AspectRatio,
					}),
				} or nil,
			}),
			props[Children],
		},
	})
end
