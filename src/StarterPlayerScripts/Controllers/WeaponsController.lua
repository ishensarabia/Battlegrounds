local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Dependencies
local WeaponSystem = require(ReplicatedStorage.Source.Systems.WeaponsSystem.WeaponsSystem)

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

function WeaponsController:Dash()
    WeaponSystem.dash()
end


return WeaponsController
