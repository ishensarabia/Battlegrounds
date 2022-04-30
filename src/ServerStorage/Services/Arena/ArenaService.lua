--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Players = game:GetService("Players")
local ArenaService = Knit.CreateService {
    Name = "ArenaService",
    BlueScore = 0,
    RedScore = 0,
    CurrentBall = nil,
    Client = {},
}

ArenaService.NORMAL_RUN_SPEED = 36
ArenaService.BALL_RUN_SPEED = 52

function ArenaService:GetArena()
    local ArenaComponent = require(game.ServerStorage.Source.Components.Arena)
    return ArenaComponent:FromInstance(workspace.Arena)  
end

function ArenaService:_startGame()
    local arena = self:GetArena()
    arena:SetScoreForTeam('Blue',0)
    arena:SetScoreForTeam('Red',0)
end

function ArenaService:ThrowBall(player, clickDuration : number)
    local Ball = require(ServerStorage.Source.Components.Ball)
    local BallComponentInstance = Ball:FromInstance(self.CurrentBall)
    if (player.UserId ~= BallComponentInstance.playerID) then return end
    BallComponentInstance:Throw(player, clickDuration)
end

function ArenaService.Client:ThrowBall(player, clickDuration : number)
    return self.Server:ThrowBall(player, clickDuration)
end

function ArenaService:KnitInit()

end

function ArenaService:KnitStart()
    repeat task.wait() until Knit.ComponentsLoaded == true
    self:_startGame()
end



return ArenaService
