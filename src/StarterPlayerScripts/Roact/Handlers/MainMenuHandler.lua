local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Flipper = require(Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(Packages.Janitor)
--Assets
local InventoryIcons = require(game.ReplicatedStorage.Source.Assets.Icons.InventoryIcons)
--Components
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Components
local CurrencyFrame = require(RoactComponents.CurrencyFrame)
--Constants
local FLIPPER_SPRING_RETRACT = Flipper.Spring.new(0, {
	frequency = 4,
	dampingRatio = 0.75,
})
local FLIPPER_SPRING_EXPAND = Flipper.Spring.new(1, {
	frequency = 5,
	dampingRatio = 1,
})
--Main!

local MainMenuHandler = Roact.Component:extend("MainMenuHandler")

function MainMenuHandler:init() end

function MainMenuHandler:render()
	return Roact.createElement(
		CurrencyFrame,
		{ position = UDim2.fromScale(0.714, 0.897), size = UDim2.fromScale(0.139, 0.0816) }
	)
end

function MainMenuHandler:didMount()
	self.active = true
	local CameraController = Knit.GetController("CameraController")
	local ArenaService = Knit.GetService("ArenaService")
	local currentArenaInstance = workspace:WaitForChild("Arena")
	local cutscenePoints = currentArenaInstance.Cutscene
    --Set up main menu
    workspace.CurrentCamera.CFrame = currentArenaInstance.StartingCamera.CFrame
    task.spawn(function()        
        CameraController.isInMenu = true
        CameraController:TransitionBetweenPoints(cutscenePoints)
    end)
end

return MainMenuHandler
