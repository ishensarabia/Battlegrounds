local MainHUD = {}
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Packages = game.ReplicatedStorage.Packages
--Module dependencies
local Roact = require(Packages.Roact)
local RoactComponents = game.StarterPlayer.StarterPlayerScripts.Source.RoactComponents
--Components
local InventoryButton = require(RoactComponents.InventoryButton)

function MainHUD:Initialize()
	local MainHUD = Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			ItemsInventory = Roact.createElement(
				InventoryButton,
				{
					size = UDim2.fromScale(0.107, 0.128),
					position = UDim2.fromScale(0.703, 0.848),
					typeOfInventory = "ItemsInventory",
					callback = function() 
                        
                    end,
				}
			),
			SuperPowersInventory = Roact.createElement("ImageButton", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.879, 0.659),
				Size = UDim2.fromScale(0.107, 0.128),
			  })
		}),
	})
	Roact.mount(MainHUD, PlayerGui, "MainHUD")
	return true
end

return MainHUD:Initialize()
