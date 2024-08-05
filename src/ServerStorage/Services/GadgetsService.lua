local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Dependencies
local GadgetsSystem = require(ReplicatedStorage.Source.Systems.GadgetsSystem.GadgetSystem)

local GadgetsService = Knit.CreateService {
    Name = "GadgetsService",
    Client = {},
}


function GadgetsService:KnitStart()
    GadgetsSystem.setup()
end


function GadgetsService:KnitInit()
    
end


return GadgetsService
