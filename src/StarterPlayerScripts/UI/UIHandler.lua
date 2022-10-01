local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Knit = require(ReplicatedStorage.Packages.Knit)
--Roact components
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
local RoactCoreComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Core
-- local InventoryComponent = require(RoactCoreComponents.Inventory)
local MainMenuComponent = require(RoactComponents.MainMenu)

local UIHandler = {}

UIHandler.mode = "MainMenu"

function UIHandler:Initialize()
	-- local MainHUD = Roact.createElement("ScreenGui", {
	-- 	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	-- }, {
	-- 	Main = Roact.createElement("Frame", {
	-- 		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	-- 		BackgroundTransparency = 1,
	-- 		Size = UDim2.fromScale(1, 1),
	-- 	}, {
	-- 		InventoryFrame = Roact.createElement(InventoryComponent, {
	-- 			size = UDim2.fromScale(1, 1),
	-- 			buttonsFramePosition = UDim2.fromScale(0.653, 0.496),
	-- 			buttonsFrameSize = UDim2.fromScale(0.347, 0.504),
	-- 		}),
	-- 	}),
	-- })

	--To do parent the components here and delete RoactHandlers
	local MainMenu = Roact.createElement(MainMenuComponent, {
		bottomBar = { position = UDim2.fromScale(-0.00428, 0.961), size = UDim2.fromOffset(1409, 28) },
		topBar = { position = UDim2.fromScale(0, 0) },
		playButton = { position = UDim2.fromScale(0.411, 0.781) },
		battleCoinsFrame = { position = UDim2.fromScale(0.853, 0.898) },
		battleGemsFrame = { position = UDim2.fromScale(0.714, 0.897) },
		inventory = { position = UDim2.fromScale(0.3, 0.3) },
		playerPreview = {
			position = UDim2.fromScale(0.266, 0.196),
			humanoidDescription = Players:GetHumanoidDescriptionFromUserId(Players.LocalPlayer.UserId),
		},
	})
	-- Roact.mount(MainHUD, PlayerGui, "MainHUD")
	Roact.mount(MainMenu, PlayerGui, "MainMenu")
	return true
end

return UIHandler:Initialize()
