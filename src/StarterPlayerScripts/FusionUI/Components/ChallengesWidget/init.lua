--[=[
	@class init
]=]

local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local FusionComponents = StarterPlayer.StarterPlayerScripts.Source.FusionUI.FusionComponents
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Text = require(FusionComponents.Text)
local VStack = require(FusionComponents.VStack)
local HStack = require(FusionComponents.HStack)
local StyledButton = require(FusionComponents.StyledButton)
local FusionGlobalSettings = require(FusionComponents.FusionGlobalSettings)
local Button = require(FusionComponents.Button)
local CloseButton = require(FusionComponents.CloseButton)
local SpringAnimate = require(FusionComponents.SpringAnimate)
local FormatText = require(ReplicatedStorage.Source.Modules.Util.FormatText)

local AutoResizeScrolling = require(FusionComponents.AutoResizeScrolling)

local PADDING = FusionGlobalSettings.PADDING / 3
local BACKGROUND_COLOR = FusionGlobalSettings.BACKGROUND_COLOR

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Cleanup = Fusion.Cleanup
local ForValues = Fusion.ForValues

local function GamepassButton(props: {
	Id: number,
	Title: string,
	Price: number,
	Owned: any,
})
	return Button({
		LayoutOrder = 999,
		BackgroundTransparency = 0,
		BackgroundColor3 = BACKGROUND_COLOR,
		OnClick = function()
			MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, props.Id)
		end,
		[Children] = {
			New("UICorner")({
				CornerRadius = UDim.new(0, 5),
			}),
			VStack({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0.2, 0),
				[Children] = {
					CoinDisplay = HStack({
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, PADDING),
						Size = UDim2.fromScale(0.8, 0.3),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.1),
						[Children] = {
							Amount = Text.Title({
								Text = props.Title,
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextScaled = true,
								Size = UDim2.fromScale(1, 1),
								AutomaticSize = Enum.AutomaticSize.X,
								BackgroundTransparency = 1,
							}),
						},
					}),
					Amount = Text.Title({
						Text = Computed(function(use)
							local owned = props.Owned

							print("owned", owned)

							if owned then
								return `Owned`
							end

							return ` {FormatText.To_comma_value(props.Price)}`
						end),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						Size = UDim2.fromScale(0.6, 0.2),

						BackgroundTransparency = 1,
					}),
				},
			}),
		},
	})
end

return function(props)
	-- Computed(function(use)
	-- 	print(use(props.GamepassButtons))
	-- end)

	return New("Frame")({
		Name = "ChallengesFrame",
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.703, 0.148),
		Size = UDim2.fromScale(0.288, 0.727),
		ZIndex = 2,

		[Children] = {

			CloseButton =  CloseButton({
				Size = UDim2.fromScale(0.1, 0.1),
				Position = UDim2.fromScale(0.9, 0.1),
				AnchorPoint = Vector2.new(0.5, 0),
				Visible = true,
				OnClick = function()
					warn("Closebutton clicked")
				end,
				ImageColor3 = Color3.fromRGB(255, 255, 255),
			}),

			UICorner = New("UICorner")({
				Name = "UICorner",
			}),

			New("TextLabel")({
				Name = "DailyChallengesTextLabel",
				FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				Text = "DAILY CHALLENGES",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = 0.3,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.195, -0.0758),
				Size = UDim2.fromScale(0.649, 0.0747),
				ZIndex = 2,
			}),

			TextLable = New("TextLabel")({
				Name = "WeeklyChallengesTextLabel",
				FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				Text = "WEEKLY CHALLENGES",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = 0.3,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.127, 0.463),
				Size = UDim2.fromScale(0.741, 0.0799),
				ZIndex = 2,
			}),

			Frame = New("Frame")({
				Name = "SeparatorFrame",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.fromScale(0, -0.0124),
				Size = UDim2.fromScale(0.997, 0.0113),

				[Children] = {
					New("UICorner")({
						Name = "UICorner",
					}),

					New("UIStroke")({
						Name = "UIStroke",
					}),
				},
			}),

			Frame = New("Frame")({
				Name = "SeparatorFrame",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.fromScale(0.00181, 0.537),
				Size = UDim2.fromScale(0.997, 0.0113),

				[Children] = {
					New("UICorner")({
						Name = "UICorner",
					}),

					New("UIStroke")({
						Name = "UIStroke",
					}),
				},
			}),

			ImageLabel = New("ImageLabel")({
				Name = "BackgroundImage",
				Image = "rbxassetid://15425458706",
				ImageTransparency = 0.34,
				TileSize = UDim2.fromScale(0.2, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(-0.127, -0.0826),
				Size = UDim2.fromScale(1.16, 1.06),
				ZIndex = -5,

				[Children] = {
					New("UIGradient")({
						Name = "UIGradient",
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 26, 26)),
							ColorSequenceKeypoint.new(0.163, Color3.fromRGB(209, 209, 209)),
							ColorSequenceKeypoint.new(0.564, Color3.fromRGB(194, 194, 194)),
							ColorSequenceKeypoint.new(0.772, Color3.fromRGB(53, 53, 53)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
						}),
						Rotation = 78,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(0.131, 0.851),
							NumberSequenceKeypoint.new(0.204, 0.616),
							NumberSequenceKeypoint.new(0.456, 0),
							NumberSequenceKeypoint.new(0.52, 0),
							NumberSequenceKeypoint.new(0.575, 0),
							NumberSequenceKeypoint.new(0.842, 0.606),
							NumberSequenceKeypoint.new(0.92, 0.895),
							NumberSequenceKeypoint.new(0.973, 0.954),
							NumberSequenceKeypoint.new(1, 1),
						}),
					}),
				},
			}),

			BottomFrame = New("Frame")({
				Name = "TopBar",
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Position = UDim2.fromScale(-0.127, -0.0696),
				Size = UDim2.fromScale(1.17, 0.0569),

				[Children] = {
					New("UICorner")({
						Name = "UICorner",
					}),
				},
			}),

			TopFrame = New("Frame")({
				Name = "TopBar",
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Position = UDim2.fromScale(-0.127, 0.473),
				Size = UDim2.fromScale(1.17, 0.0637),

				[Children] = {
					New("UICorner")({
						Name = "UICorner",
					}),
				},
			}),
		},
	})
end
