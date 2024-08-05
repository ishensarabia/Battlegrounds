local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Dependencies
local GadgetsSystem = require(ReplicatedStorage.Source.Systems.GadgetsSystem.GadgetSystem)

local GadgetsController = Knit.CreateController { Name = "GadgetsController" }


function GadgetsController:KnitStart()
    GadgetsSystem.setup()
end


function GadgetsController:KnitInit()
    
end


return GadgetsController
