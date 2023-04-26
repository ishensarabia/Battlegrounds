local Knit = require(game.ReplicatedStorage.Packages.Knit)

local UIController = Knit.CreateController({ Name = "UIController" })
local UIModules = script.Parent.Parent.UI_Widgets

function UIController:KnitStart()
	for key, child in (UIModules:GetChildren()) do
		if child:IsA("ModuleScript") then
			require(child)
		end
	end
end

function UIController:KnitInit() end

return UIController
