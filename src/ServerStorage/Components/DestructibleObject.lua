local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Component = require(game.ReplicatedStorage.Packages.Component)
local TweenObject = require(game.ServerStorage.Source.Modules.TweenObject)
local Players = game:GetService("Players")
--Services
local TweenService = game:GetService("TweenService")

local DestructibleObject = Component.new({
Tag = 'DestructibleObject' 
})


function DestructibleObject:Construct()
    self.isConstructed = true
    self._janitor = Janitor.new()
    self._constructorID = 0
    self._partsCFrames = {}
    self._tweenPromises = {}
    self.constructPrompt = nil
end

function DestructibleObject:DestroyObject()
    --Setup proximity prompt
    self.constructPrompt = self.Instance.Interactable.BuildPart:FindFirstChild('ProximityPrompt') or Instance.new('ProximityPrompt')
    self._janitor:Add(self.constructPrompt)
    self.constructPrompt.Parent = self.Instance.Interactable.BuildPart
    self.constructPrompt.ActionText = 'Build'
    
    self._janitor:Add(self.constructPrompt.PromptButtonHoldBegan:Connect(function(player)
        self:ConstructObject(player)
    end))

    self._janitor:Add(self.constructPrompt.Triggered:Connect(function(player)
        self:ConstructObject(player)
        self._janitor:Cleanup()
    end))

    self._janitor:Add(self.constructPrompt.PromptButtonHoldEnded:Connect(function(player)
        -- if (not self.isConstructed) then        
            self:CancelConstruction()
        -- end
    end))

    self.isConstructed = false

    for key, child in pairs(self.Instance:GetChildren()) do
        if (child:IsA('BasePart')) then
            child.Anchored = false
        end
    end
end

function DestructibleObject:Start()
    self:_setModelPartCFrames()
    self:DestroyObject()
end

function DestructibleObject:_setModelPartCFrames()
    for index, child in pairs(self.Instance:GetChildren()) do
        if (child:IsA('BasePart')) then
            if (child:GetAttribute('PartIndex')) then            
                self._partsCFrames[child:GetAttribute('PartIndex')] = child.CFrame
            else
                error('No index part was set for the parts of the model')    
            end
        end
    end
end

function DestructibleObject:_setBuildPromptTime()
    local promptTime = 0
    for index, child in pairs(self.Instance:GetChildren()) do
        if (child:IsA('BasePart')) then
            local function a(b,c)
                return c*b
            end
            local magnitude = (child.CFrame.Position - self._partsCFrames[child:GetAttribute('PartIndex')].Position).Magnitude
            if (magnitude > 25) then            
                local length = #self.Instance:GetChildren() / index / #self.Instance:GetChildren()
                promptTime += length
            end
            
        end
    end
    if (promptTime < 1) then
        promptTime = 1
    end
    warn(promptTime)         
    return promptTime
end

function DestructibleObject:_setBuildTime()
    self.constructPrompt.HoldDuration = self:_setBuildPromptTime()
end

function DestructibleObject:ConstructObject(player)
    local buildTime = 0
    for index, child in pairs(self.Instance:GetChildren()) do
        if (child:IsA('BasePart')) then
            local magnitude = (child.CFrame.Position - self._partsCFrames[child:GetAttribute('PartIndex')].Position).Magnitude
            if (magnitude > 25) then            
                local length = #self.Instance:GetChildren() / index / #self.Instance:GetChildren()
                buildTime += length
            end
            if (buildTime < 1) then
                buildTime = 1
            end
            local promise = TweenObject.TweenBasePart(child, TweenInfo.new(buildTime), {CFrame = self._partsCFrames[child:GetAttribute('PartIndex')]})
            self._tweenPromises[child:GetAttribute('PartIndex')] = promise
            child.CanCollide = false
            child.Anchored = true
        end
    end

    for key, child in pairs(self.Instance:GetChildren()) do
        if (child:IsA('BasePart')) then
            child.CanCollide = true
        end
    end
end

function DestructibleObject:CancelConstruction()
    for key, child in pairs(self.Instance:GetChildren()) do
        if (child:IsA('BasePart')) then
            child.Anchored = false
            child.CanCollide = true
            self._tweenPromises[child:GetAttribute('PartIndex')]:cancel()
        end
    end
    self:_setBuildTime()
end

function DestructibleObject:Stop()
    
end


return DestructibleObject
