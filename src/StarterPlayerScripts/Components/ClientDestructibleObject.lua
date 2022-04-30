local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Component = require(game.ReplicatedStorage.Packages.Component)
--Constants
local LOCAL_COMPONENTS_PATH = game.StarterPlayer.StarterPlayerScripts.Source.Components

local Conditions = {}
function Conditions.ShouldConstruct(component)
    return component.Instance.Interactable.BuildPart:FindFirstChildOfClass('ProximityPrompt')
end

local ClientDestructibleObject = Component.new({
    Tag = 'DestructibleObject',
    Extensions = {Conditions}
})


function ClientDestructibleObject:Construct()
    self._janitor = Janitor.new()
    self.constructPrompt = nil
end


function ClientDestructibleObject:Start()
    self.constructPrompt = self.Instance.Interactable.BuildPart:FindFirstChildOfClass('ProximityPrompt')
    self._janitor:Add(self.constructPrompt.PromptShown:Connect(function()
        Knit.GetService('DestructibleObjectService'):SetBuildTime(self.Instance)
    end))
end


function ClientDestructibleObject:Stop()
    
end

function ClientDestructibleObject:HeartbeatUpdate(deltaTime)
   
end

return ClientDestructibleObject
