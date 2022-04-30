--Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Component = require(ReplicatedStorage.Packages.Component)

local Goal = Component.new({Tag = 'Goal'})

--Constants
local BALL_TAG = 'Ball'

function Goal:Construct()
    
    self._janitor = Janitor.new()
    return self
end

function Goal:_setColorsForNet(color)
    for key, value in pairs(self.Instance:GetDescendants()) do
        if (value:IsA('BasePart')) then
            value.Color = color
        end
    end
    self.Instance.Top.BillboardGui.Score.TextColor3 = color
end

function Goal:_observeScore(teamName)
    local arena = Knit.GetService('ArenaService'):GetArena()
    local scoreAttributeName = teamName .. 'Score'
    local function ScoreChanged()
        local score = arena.Instance:GetAttribute(scoreAttributeName)
        self.Instance.Top.BillboardGui.Score.Text = tostring(score)
    end
   self._janitor:Add(arena:ObserveScore(teamName, ScoreChanged))
end

function Goal:_setupScoring(teamName)
    self.Instance.Sensor.Touched:Connect(function(part)
        if (CollectionService:HasTag(part,BALL_TAG)) then
            part:Destroy()
            local arena = Knit.GetService('ArenaService'):GetArena()
            arena:SetScoreForTeam(teamName, arena:GetScoreFromTeam(teamName) + 1)
        end
    end)
end

function Goal:Start()
    local teamName = self.Instance.Name
    local team = game:GetService("Teams")[teamName]
    local teamColor = team.TeamColor.Color
    self:_setColorsForNet(teamColor)
    self:_observeScore(teamName)
    self:_setupScoring(teamName)
end    

function Goal:Destroy()
    self._janitor:Cleanup()
end

return Goal
