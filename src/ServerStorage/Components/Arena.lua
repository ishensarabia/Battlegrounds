--****************************************************
-- File: Arena.lua
--
-- Purpose: Arena object containing all the necessary functions for the game.
--
-- Written By: Ishen
--
-- Compiler: Visual Studio Code
--****************************************************

--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(Knit.Util.Promise)
--Assets
local BALL_PREFAB =  game:GetService('ServerStorage').Assets.Ball
--Constants
local RESPAWN_BALL_TIME = 3


local Arena = Component.new({
    Tag = 'Arena',
    Ancestors = {workspace}
})
--****************************************************
-- Function: ArenaComponent:Construct
--
-- Purpose: Constructs the object with all the neccessary variables to assign.
--****************************************************

function Arena:Construct()
    self._janitor = Janitor.new()
    self._respawnSignal = Signal.new(self._janitor)
end

function Arena:Start()
    self._respawnSignal:Connect(function()        
        self:_spawnBall()
    end)
    self._respawnSignal:Fire()
end

function Arena:ObserveScore(teamName : string, handler) : RBXScriptSignal
    local teamScore = teamName .. 'Score'
    handler(self.Instance:GetAttribute(teamScore))
    local connection = self.Instance:GetAttributeChangedSignal(teamScore):Connect(function()
        handler(self.Instance:GetAttribute(teamScore))
    end)
    self._janitor:Add(connection)
    return connection 
end

function Arena:GetScoreFromTeam(teamName : string)
    local teamScore = teamName .. 'Score'
    return self.Instance:GetAttribute(teamScore)
end

--****************************************************
-- Function: ArenaComponent:SetScore
--
-- Purpose: Sets scores to teams during the match.
--****************************************************

function Arena:SetScoreForTeam(teamName : string, score : number)
    local teamScore = teamName .. 'Score'
    self.Instance:SetAttribute(teamScore, score)
end


function Arena:CleanUp()
    self._janitor:Cleanup()
end

function Arena:_spawnBall()
    local ball = BALL_PREFAB:Clone()
    ball.Parent = self.Instance
    ball.CFrame = self.Instance.Center.Attachment.WorldCFrame
    self._janitor:Add(ball)
    Knit.GetService('ArenaService').CurrentBall = ball
    self._janitor:Add(ball:GetPropertyChangedSignal('Parent'):Connect(function()
        if (not ball.Parent) then
            self._janitor:AddPromise(Promise.delay(RESPAWN_BALL_TIME)):andThen(function()                
                self._respawnSignal:Fire()
            end)
        end
    end))
end

return Arena