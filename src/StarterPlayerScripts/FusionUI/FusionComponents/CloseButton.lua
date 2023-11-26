--[=[
	@class CloseButton
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local FusionComponents = StarterPlayer.StarterPlayerScripts.Source.FusionUI.FusionComponents

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Button = require(FusionComponents.Button)
local HStack = require(FusionComponents.HStack)
local VStack = require(FusionComponents.VStack)
local Text = require(FusionComponents.Text)
local FusionGlobalSettings = require(FusionComponents.FusionGlobalSettings)

local PADDING = FusionGlobalSettings.PADDING

local New = Fusion.New
local Children = Fusion.Children

return function(props)
	return Button({
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = 1,
		OnClick = props.OnClick,
		BackgroundColor3 = props.BackgroundColor3,
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		Visible = props.Visible,
		[Children] = {
			UICorner = New("UICorner")({
				CornerRadius = UDim.new(0, 5),
			}),
			VStack({
				Size = UDim2.fromScale(1, 1),
				Padding = UDim.new(0, -10),
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				[Children] = {
					Icon = props.Image and New("ImageLabel")({
						Size = UDim2.fromScale(0.8, 0.8),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Image = "rbxassetid://15425634373",
						ScaleType = Enum.ScaleType.Fit,
						ImageColor3 = props.ImageColor3,
						BackgroundTransparency = 1,
					}) or nil,
				},
			}),
		},
	})
end
