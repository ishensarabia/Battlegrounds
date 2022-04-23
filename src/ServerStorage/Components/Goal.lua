--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Component = require(ReplicatedStorage.Packages.Component)

local GoalComponent = Component.new({Tag = 'Goal'})

function GoalComponent:Construct()
    
    self._janitor = Janitor.new()
    warn('Goal created')
    return self
end

function GoalComponent:_setColorsForNet(color)
    for key, value in pairs(self.Instance:GetDescendants()) do
        if (value:IsA('BasePart')) then
            value.Color = color
        end
    end
    self.Instance.Top.BillboardGui.Score.TextColor3 = color
end

function GoalComponent:_observeScore(teamName)
    local arena = Knit.GetService('ArenaService'):GetArena()
    local scoreAttributeName = teamName .. 'Score'
    local function ScoreChanged()
        warn('Score changed')
        local score = arena.Instance:GetAttribute(scoreAttributeName)
        self.Instance.Top.BillboardGui.Score.Text = tostring(score)
    end
   self._janitor:Add(arena:ObserveScore(teamName, ScoreChanged))
end

function GoalComponent:Start()
    local teamName = self.Instance.Name
    local team = game:GetService("Teams")[teamName]
    local teamColor = team.TeamColor.Color
    self:_setColorsForNet(teamColor)
    self:_observeScore(teamName)
end    

function GoalComponent:Destroy()
    self._janitor:Cleanup()
end

return GoalComponent
