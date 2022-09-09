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

local MainMenu = Roact.Component:extend("MainMenuHandler")

function MainMenu:init()
    self.active = true
end

function MainMenu:render()
	return  Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		IgnoreGuiInset = true,
	}, {
		bottomBar = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(47, 47, 47),
			Position = UDim2.fromScale(-0.00428, 0.961),
			Size = UDim2.fromOffset(1409, 28),
		}),

		topBar = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(47, 47, 47),
			Size = UDim2.fromScale(1.17, 0.0867),
		}),

		battleCoinsFrame = Roact.createElement(
			CurrencyFrame,
			{
				position = UDim2.fromScale(0.0888, 0.0581),
				size = UDim2.fromScale(0.236, 0.859),
				currency = "battleCoins",
			}
		),
		battleGemsFrame = Roact.createElement(
			CurrencyFrame,
			{
				position = UDim2.fromScale(0.714, 0.897),
				size = UDim2.fromScale(0.139, 0.0816),
				currency = "battleGems",
			}
		),
end

function MainMenu:didMount()
	self.active = true
	local CameraController = Knit.GetController("CameraController")
	local currentArenaInstance = workspace:WaitForChild("Arena")
	local cutscenePoints = currentArenaInstance.Cutscene
    --Set up main menu cutscene
    workspace.CurrentCamera.CFrame = currentArenaInstance.StartingCamera.CFrame
    task.spawn(function()        
        while self.active do            
            CameraController:TransitionBetweenPoints(cutscenePoints)
        end
    end)
end

return MainMenu
