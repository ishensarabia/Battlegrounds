--[=[
	@class init
]=]

local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local FusionComponents = (StarterPlayer.StarterPlayerScripts.Source.FusionUI.FusionComponents)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Text = require(FusionComponents.Text)
local VStack = require(FusionComponents.VStack)
local HStack = require(FusionComponents.HStack)
local StyledButton = require(FusionComponents.StyledButton)
local FusionGlobalSettings = require(FusionComponents.FusionGlobalSettings)
local Button = require(FusionComponents.Button)
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
	local blur = New("BlurEffect")({
		Size = SpringAnimate(Computed(function(use)
			return props.Visible and 24 or 0
		end)),
		Parent = Lighting,
	})

	-- Computed(function(use)
	-- 	print(use(props.GamepassButtons))
	-- end)

	return New("Frame")({
		[Cleanup] = { blur },
		Parent = props.Parent,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Children] = {
			Background = New("Frame")({
				Size = UDim2.fromScale(2, 2),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = SpringAnimate(Computed(function(use)
					return props.Visible and 0.5 or 1
				end)),
				ZIndex = 0,
			}),
			LoadoutButton = StyledButton({
				Size = UDim2.fromScale(0.1, 0.073),
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0.87, 0.4),
				Image = "rbxassetid://11454268899",
				BackgroundColor3 =  BACKGROUND_COLOR,
				Text = "LOADOUT",
				TextColor3 = Color3.fromRGB(255, 255, 255),

			}),

			StoreButton = StyledButton({
				Size = UDim2.fromScale(0.1, 0.073),
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0.87, 0.6),
				Image = "rbxassetid://13600183909",
				BackgroundColor3 =  BACKGROUND_COLOR,
				Text = "STORE",
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}),

			BattlepassButton = StyledButton({
				Size = UDim2.fromScale(0.1, 0.073),
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0.033, 0.6),
				Image = "rbxassetid://14944714812",
				BackgroundColor3 =  BACKGROUND_COLOR,
				Text = "BATTLEPASS",
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}),

			ChallengesButton = StyledButton({
				Size = UDim2.fromScale(0.1, 0.073),
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0.033, 0.4),
				Image = "rbxassetid://13474525765",
				BackgroundColor3 =  BACKGROUND_COLOR,
				Text = "CHALLENGES",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				OnClick =  props.ChallengesButtonCallback
			}),

			Shop = New("Frame")({
				Parent = props.Parent,
				Size = UDim2.fromScale(1, 1),
				Position = SpringAnimate(Computed(function(use)
					return props.Visible and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0.5, 1.5)
				end)),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				[Children] = {
					Corner = New("UICorner")({
						CornerRadius = UDim.new(0, 5),
					}),
					AspectRatio = New("UIAspectRatioConstraint")({
						AspectRatio = 2,
					}),
					Padding = New("UIPadding")({
						PaddingTop = UDim.new(0, PADDING),
						PaddingBottom = UDim.new(0, PADDING),
						PaddingLeft = UDim.new(0, PADDING),
						PaddingRight = UDim.new(0, PADDING),
					}),
					AutoResizeScrolling.Grid({
						Size = UDim2.fromScale(1, 0.9),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0, 0.1),
						CellSize = UDim2.fromScale(0.2, 1),
						AspectRatio = 1.5,
						SortOrder = Enum.SortOrder.LayoutOrder,
						[Children] = {
							-- ForValues(props.CurrencyButtons, function(_, info)
							-- 	return Button({
							-- 		LayoutOrder = info.LayoutOrder,
							-- 		BackgroundTransparency = 0,
							-- 		BackgroundColor3 = BACKGROUND_COLOR,
							-- 		OnClick = function()
							-- 			props.BuyCurrency(info.Amount)
							-- 		end,
							-- 		[Children] = {
							-- 			New("UICorner")({
							-- 				CornerRadius = UDim.new(0, 5),
							-- 			}),
							-- 			VStack({
							-- 				HorizontalAlignment = Enum.HorizontalAlignment.Center,
							-- 				VerticalAlignment = Enum.VerticalAlignment.Center,
							-- 				Padding = UDim.new(0.2, 0),
							-- 				[Children] = {
							-- 					CoinDisplay = HStack({
							-- 						HorizontalAlignment = Enum.HorizontalAlignment.Center,
							-- 						VerticalAlignment = Enum.VerticalAlignment.Center,
							-- 						Padding = UDim.new(0, PADDING),
							-- 						Size = UDim2.fromScale(0.8, 0.3),
							-- 						AnchorPoint = Vector2.new(0.5, 0),
							-- 						Position = UDim2.fromScale(0.5, 0.1),
							-- 						[Children] = {
							-- 							CoinsImage = New("ImageLabel")({
							-- 								Size = UDim2.fromScale(1, 1),
							-- 								BackgroundTransparency = 1,
							-- 								Image = "rbxassetid://14959587232",
							-- 								SizeConstraint = Enum.SizeConstraint.RelativeYY,
							-- 								ScaleType = Enum.ScaleType.Fit,
							-- 							}),
							-- 							Amount = Text.Title({
							-- 								Text = FormatText.To_comma_value(info.Amount),
							-- 								TextColor3 = Color3.fromRGB(255, 255, 255),
							-- 								TextScaled = true,
							-- 								Size = UDim2.fromScale(0.6, 1),
							-- 								AutomaticSize = Enum.AutomaticSize.X,
							-- 								BackgroundTransparency = 1,
							-- 							}),
							-- 						},
							-- 					}),
							-- 					Amount = Text.Title({
							-- 						Text = ` {FormatText.To_comma_value(info.Price)}`,
							-- 						TextColor3 = Color3.fromRGB(255, 255, 255),
							-- 						TextScaled = true,
							-- 						Size = UDim2.fromScale(0.6, 0.2),

							-- 						BackgroundTransparency = 1,
							-- 					}),
							-- 				},
							-- 			}),
							-- 		},
							-- 	})
							-- end, Fusion.cleanup),
							-- ForValues(props.GamepassButtons, function(_, info)
							-- 	return GamepassButton(info)
							-- end, Fusion.cleanup),
						},
					}),
				},
			}),
		},
	})
end
