local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local ArenaService = Knit.CreateService {
    Name = "ArenaService",
    BlueScore = 0,
    RedScore = 0,
    Client = {},
}

function ArenaService:GetArena()
    local ArenaComponent = require(game.ServerStorage.Source.Components.Arena)
    return ArenaComponent:FromInstance(workspace.Arena)
end

function ArenaService:_startGame()
    local arena = self:GetArena()
    arena:SetScoreForTeam('Blue',0)
    arena:SetScoreForTeam('Red',0)
end

function ArenaService:KnitInit()
    
end

function ArenaService:KnitStart()
    repeat task.wait() until Knit.ComponentsLoaded == true
    self:_startGame()
end



return ArenaService
