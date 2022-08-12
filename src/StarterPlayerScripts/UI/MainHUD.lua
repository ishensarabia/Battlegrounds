local MainHUD = {}
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
--Roact components
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.RoactComponents
local InventoryHandler = require(RoactComponents.InventoryHandler)

function MainHUD:Initialize()
	local MainHUD = Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Main = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			InventoryFrame = Roact.createElement(InventoryHandler, 
		{
				size = UDim2.fromScale(1, 1),
				buttonsFramePosition = UDim2.fromScale(0.653, 0.496), buttonsFrameSize = UDim2.fromScale(0.347, 0.504),
			})
		}),
	})
	Roact.mount(MainHUD, PlayerGui, "MainHUD")
	return true
end

return MainHUD:Initialize()
