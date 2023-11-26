--[=[
	@class AutoResizeScrolling
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnChange = Fusion.OnChange
local Value = Fusion.Value

return {
	List = function(props)
		local canvasSize = Value(UDim2.fromScale(0, 0))

		local padding = props.Padding or 0
		local fillDirection = props.FillDirection or Enum.FillDirection.Vertical

		return New("ScrollingFrame")({
			CanvasSize = canvasSize,
			Size = props.Size or UDim2.fromScale(1, 1),
			Position = props.Position or UDim2.fromScale(0, 0),
			AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
			BackgroundTransparency = props.BackgroundTransparency or 1,
			LayoutOrder = props.LayoutOrder,
			ScrollingDirection = props.ScrollingDirection or Enum.ScrollingDirection.Y,
			ScrollBarThickness = props.ScrollBarThickness,
			[Children] = {
				List = New("UIListLayout")({
					FillDirection = fillDirection,
					HorizontalAlignment = props.HorizontalAlignment,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = props.VerticalAlignment,
					Padding = UDim.new(0, padding),
					[OnChange("AbsoluteContentSize")] = function(newSize)
						if fillDirection == Enum.FillDirection.Vertical then
							canvasSize:set(UDim2.fromOffset(0, newSize.Y + padding * 2))
						else
							canvasSize:set(UDim2.fromOffset(newSize.X + padding * 2, 0))
						end
					end,
				}),
				props[Children],
			},
		})
	end,
	Grid = function(props)
		local canvasSize = Value(UDim2.fromScale(0, 0))

		local padding = props.Padding or 0

		return New("ScrollingFrame")({
			CanvasSize = canvasSize,
			Size = props.Size or UDim2.fromScale(1, 1),
			Position = props.Position or UDim2.fromScale(0, 0),
			AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
			BackgroundTransparency = props.BackgroundTransparency or 1,
			LayoutOrder = props.LayoutOrder,
			[Children] = {
				List = New("UIGridLayout")({
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
					[OnChange("AbsoluteContentSize")] = function(newSize)
						canvasSize:set(UDim2.fromOffset(0, newSize.Y + padding * 2))
					end,
				}),
				props[Children],
			},
		})
	end,
}
