local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Component = require(game.ReplicatedStorage.Packages.Component)
local Animations = require(game.ReplicatedStorage.Source.Assets.Animations)
--Constants
local LOCAL_COMPONENTS_PATH = game.StarterPlayer.StarterPlayerScripts.Source.Components

local Conditions = {}
function Conditions.ShouldConstruct(component)
    return component.Instance.Interactable.BuildPart.Attachment:FindFirstChildOfClass('ProximityPrompt')
end

local ClientDestructibleObject = Component.new({
    Tag = 'DestructibleObject',
    Extensions = {Conditions}
})


function ClientDestructibleObject:Construct()
    self._janitor = Janitor.new()
    self.constructPrompts = {}
end

function ClientDestructibleObject:_setUpAnimation()
    local buildingAnimation = Instance.new('Animation')
    buildingAnimation.AnimationId = Animations['Building']
    self._janitor:Add(buildingAnimation)
    
    Knit.Player.CharacterAdded:Wait()
    local animator = Knit.Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator')
    
    local buildingAnimationTrack = animator:LoadAnimation(buildingAnimation)
    buildingAnimationTrack.Priority = Enum.AnimationPriority.Action
    buildingAnimationTrack.Looped = true
    
    self._janitor:Add(buildingAnimationTrack)
    return buildingAnimationTrack
end

function ClientDestructibleObject:Start()
    self._buildingAnimationTrack = self:_setUpAnimation()
        --Setup proximity prompts
    for index, child in pairs(self.Instance.Interactable:GetChildren()) do
        local constructPrompt = child.Attachment:WaitForChild('ProximityPrompt') 
        table.insert(self.constructPrompts, constructPrompt)
        self._janitor:Add(constructPrompt)

        self._janitor:Add(constructPrompt.PromptShown:Connect(function()
            Knit.GetService('DestructibleObjectService'):SetBuildTime(self.Instance)
        end))

        self._janitor:Add(constructPrompt.PromptButtonHoldBegan:Connect(function(player)
            self._buildingAnimationTrack:Play()
        end))
        
        self._janitor:Add(constructPrompt.Triggered:Connect(function(player)

        end))
        
        self._janitor:Add(constructPrompt.PromptButtonHoldEnded:Connect(function(player)
            self._buildingAnimationTrack:Stop(0.5)
        end))
        --Listen for new prompts
        self._janitor:Add(child.Attachment.ChildAdded:Connect(function(constructPrompt)
            if (constructPrompt:IsA('ProximityPrompt')) then
                self._janitor:Add(constructPrompt.PromptShown:Connect(function()
                    Knit.GetService('DestructibleObjectService'):SetBuildTime(self.Instance)
                end))
        
                self._janitor:Add(constructPrompt.PromptButtonHoldBegan:Connect(function(player)
                    self._buildingAnimationTrack:Play()
                end))
                
                self._janitor:Add(constructPrompt.Triggered:Connect(function(player)
        
                end))
                
                self._janitor:Add(constructPrompt.PromptButtonHoldEnded:Connect(function(player)
                    self._buildingAnimationTrack:Stop(0.5)
                end))
            end
        end))
    end

    
end


function ClientDestructibleObject:Stop()
    self._janitor:Cleanup()
end

function ClientDestructibleObject:HeartbeatUpdate(deltaTime)
   
end

return ClientDestructibleObject
