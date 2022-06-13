local Knit = require(game.ReplicatedStorage.Packages.Knit)

local UIController = Knit.CreateController { Name = "UIController" }
local UIModules = script.Parent.Parent.UI

function UIController:KnitStart()
    for key, child in (UIModules:GetChildren()) do
        assert( child:IsA("ModuleScript"), "%s child is not a module script")
        require(child)
    end
end


function UIController:KnitInit()
    
end


return UIController
