local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local Knit = require(ReplicatedStorage.Packages.Knit)
--Roact components
local RoactHandlers = game.StarterPlayer.StarterPlayerScripts.Source.Roact.Handlers
local InventoryHandler = require(RoactHandlers.InventoryHandler)
local MainMenuHandler = require(RoactHandlers.MainMenuHandler)

local UIBootstrap = {}

UIBootstrap.mode = "MainMenu"

function UIBootstrap:Initialize()
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

	
	local MainMenu = Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		IgnoreGuiInset = true
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
		mainMenu = Roact.createElement(MainMenuHandler,{},nil)
	})
	Roact.mount(MainHUD, PlayerGui, "MainHUD")
	Roact.mount(MainMenu, PlayerGui, "MainMenu")
	return true
end

return UIBootstrap:Initialize()
