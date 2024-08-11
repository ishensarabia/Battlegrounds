local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Dependencies
local WeaponsSystem = require(ReplicatedStorage.Source.Systems.WeaponsSystem.WeaponsSystem)

local WeaponsController = Knit.CreateController {
    Name = "WeaponsController",
    Client = {},
}


function WeaponsController:KnitStart()
    
end


function WeaponsController:KnitInit()
    if (not WeaponsSystem.doingSetup and not WeaponsSystem.didSetup) then
        WeaponsSystem.setup()
    end
end

function WeaponsController:Crouch(animationTrack : AnimationTrack)
    WeaponsSystem.camera.isCrouching = true
    animationTrack.Stopped:Connect(function()
        WeaponsSystem.camera.isCrouching = false
    end)
end

function WeaponsController:GetCamera()
    return WeaponsSystem.camera
end

function WeaponsController:Dash()
    WeaponsSystem.camera.isDashing = true
	task.delay(1.2, function()
		WeaponsSystem.camera.isDashing = false
	end)
end

function WeaponsController:Slide(animationTrack : AnimationTrack)
    WeaponsSystem.camera.isSliding = true
    animationTrack.Stopped:Connect(function()
        WeaponsSystem.camera.isSliding = false
    end)
end


return WeaponsController
