--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local HumanoidService = Knit.CreateService {
    Name = "HumanoidService",
    Client = {},
}


function HumanoidService:KnitStart()
    
end


function HumanoidService:KnitInit()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end)
end


return HumanoidService
