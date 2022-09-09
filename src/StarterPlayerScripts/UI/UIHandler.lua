local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Knit = require(ReplicatedStorage.Packages.Knit)
--Roact components
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
local RoactHandlers = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Handlers
local InventoryHandler = require(RoactHandlers.InventoryHandler)
local MainMenu = require(RoactComponents.MainMenu)
local CurrencyFrame = require(RoactComponents.CurrencyFrame)

local UIHandler = {}

UIHandler.mode = "MainMenu"

function UIHandler:Initialize()
	local MainHUD = Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Main = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			InventoryFrame = Roact.createElement(InventoryHandler, {
				size = UDim2.fromScale(1, 1),
				buttonsFramePosition = UDim2.fromScale(0.653, 0.496),
				buttonsFrameSize = UDim2.fromScale(0.347, 0.504),
			}),
		}),
	})

	--To do parent the components here and delete RoactHandlers
	local MainMenu =
	Roact.mount(MainHUD, PlayerGui, "MainHUD")
	Roact.mount(MainMenu, PlayerGui, "MainMenu")
	return true
end

return UIHandler:Initialize()
