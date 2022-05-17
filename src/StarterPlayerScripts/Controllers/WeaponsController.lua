local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Dependencies
local WeaponSystem = require(ReplicatedStorage.Source.Modules.WeaponsSystem.WeaponsSystem)

local WeaponsController = Knit.CreateController {
    Name = "WeaponsController",
    Client = {},
}


function WeaponsController:KnitStart()
    
end


function WeaponsController:KnitInit()
    if (not WeaponSystem.doingSetup and not WeaponSystem.didSetup) then
        WeaponSystem.setup()
    end
end


return WeaponsController
