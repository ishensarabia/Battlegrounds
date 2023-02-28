local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local VFXService = Knit.CreateService {
    Name = "VFXService",
    Client = {
        SpawnVFX = Knit.CreateSignal()
    },
}


function VFXService:KnitStart()
    
end

function VFXService:PlayerDash(player : Player)
    for index, _player in Players:GetPlayers() do
        self.Client.SpawnVFX:Fire(_player, "Dash", {HRP = player.Character.HumanoidRootPart})
    end
end

function VFXService.Client:Dash(player)
    return self.Server:PlayerDash(player)
end


function VFXService:KnitInit()
    
end


return VFXService
