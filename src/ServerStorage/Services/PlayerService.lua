--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService {
    Name = "PlayerService",
    Client = {},
}


function PlayerService:KnitStart()
    
end

function PlayerService:SpawnCharacter(player : Player)
    player:LoadCharacter()
end

function PlayerService.Client:SpawnCharacter(player)
    return self.Server:SpawnCharacter(player)
end

function PlayerService:KnitInit()
    Players.CharacterAutoLoads = false
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            character.Humanoid.Died:Connect(function(player)
                self:RegisterDead(player)
            end)
        end)
    end)
end

function PlayerService:RegisterDead(player : Player)
    local dataService = Knit.GetService("DataService")
    dataService:incrementIntValue(player, "Defeats")
end


return PlayerService
