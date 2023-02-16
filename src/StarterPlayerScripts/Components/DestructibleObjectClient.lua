local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Component = require(game.ReplicatedStorage.Packages.Component)
local Animations = require(game.ReplicatedStorage.Source.Assets.Animations)

local assets = game.ReplicatedStorage.Assets
--Constants

-- local Conditions = {}
-- function Conditions.ShouldConstruct(component)
--     if (component.Instance:FindFirstChild("Interactable")) then
--         return true
--     else
--         return false
--     end
-- end

local DestructibleObjectClient = Component.new({
    Tag = 'DestructibleObject',
    -- Extensions = {Conditions}
})

local function addParticles(part)
    local particlesAttachment = assets.Particles.Building.ParticlesAttachment:Clone()
    particlesAttachment.Parent = part
end

local function removeParticles(buildingParts)
    for index, part in (buildingParts) do
        for key, particleEmitter in (part.ParticlesAttachment:GetChildren()) do
            particleEmitter.Enabled = false
        end
        task.delay(3.99, function()            
            part.ParticlesAttachment:Destroy()
        end)
    end
end

function DestructibleObjectClient:Construct()
    self._janitor = Janitor.new()
    self.constructPrompts = {}
end

function DestructibleObjectClient:_setUpAnimation()
    local buildingAnimation = Instance.new('Animation')
    buildingAnimation.AnimationId = Animations.Building['Build']
    self._janitor:Add(buildingAnimation)
    
    Knit.Player.CharacterAdded:Wait()
    local animator = Knit.Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator')
    
    local buildingAnimationTrack = animator:LoadAnimation(buildingAnimation)
    buildingAnimationTrack.Priority = Enum.AnimationPriority.Action
    buildingAnimationTrack.Looped = true
    
    self._janitor:Add(buildingAnimationTrack)
    return buildingAnimationTrack
end

function DestructibleObjectClient:Start()
    self._buildingAnimationTrack = self:_setUpAnimation()
        --Setup proximity prompts
    for index, buildPart in (self.Instance.Interactable:GetChildren()) do
        self._janitor:Add(buildPart.Attachment.ChildAdded:Connect(function(child)
            addParticles(buildPart)
            if (child:IsA("ProximityPrompt")) then
                self._janitor:Add(child)
        
                self._janitor:Add(child.PromptShown:Connect(function()
                    Knit.GetService('DestructibleObjectService'):SetBuildTime(self.Instance)
                end))
        
                self._janitor:Add(child.PromptButtonHoldBegan:Connect(function(player)
                    self._buildingAnimationTrack:Play()
                end))
                
                self._janitor:Add(child.Triggered:Connect(function()
                    removeParticles(self.Instance.Interactable:GetChildren())
                end))

                self._janitor:Add(child.PromptButtonHoldEnded:Connect(function(player)
                    self._buildingAnimationTrack:Stop(0.5)
                end))
            end
        end))
    end
    end


function DestructibleObjectClient:Stop()
    warn("DestructibleObjectClient stopped")
    self._janitor:Cleanup()
end



return DestructibleObjectClient
