local Players = game:GetService("Players")
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Component = require(game.ReplicatedStorage.Packages.Component)
--Knit Controllers
local AnimationController = Knit.GetController("AnimationController")

local assets = game.ReplicatedStorage.Assets
--Constants

local Conditions = {}
function Conditions.ShouldConstruct(component)
    if (component.Instance:FindFirstChild("Interactable")) then
        return true
    else
        return false
    end
end

local DestructibleObjectClient = Component.new({
	Tag = "DestructibleObject",
	Extensions = {Conditions}
})

local function addParticles(part)
	local particlesAttachment = assets.Particles.Building.ParticlesAttachment:Clone()
	particlesAttachment.Parent = part
end

local function removeParticles(buildingParts)
	for index, part in buildingParts do
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


function DestructibleObjectClient:Start()
	--Setup proximity prompts
	if self.Instance and self.Instance:FindFirstChild("Interactable") then
		for index, buildPart in (self.Instance.Interactable:GetChildren()) do
			self._janitor:Add(buildPart.Attachment.ChildAdded:Connect(function(child)
				addParticles(buildPart)
				if child:IsA("ProximityPrompt") then
					self._janitor:Add(child)
	
					self._janitor:Add(child.PromptShown:Connect(function()
						Knit.GetService("DestructibleObjectService"):SetBuildTime(self.Instance)
					end))
	
					self._janitor:Add(child.PromptButtonHoldBegan:Connect(function(player)
						AnimationController:PlayAnimation("Build")
					end))
	
					self._janitor:Add(child.Triggered:Connect(function()
						removeParticles(self.Instance.Interactable:GetChildren())
					end))
	
					self._janitor:Add(child.PromptButtonHoldEnded:Connect(function(player)
						AnimationController:StopAnimation("Build")
					end))
				end
			end))
		end
	end
	--Check for new interactable parts
	self._janitor:Add(self.Instance.Interactable.ChildAdded:Connect(function(child)
		if child:IsA("BasePart") then
			self._janitor:Add(child.Attachment.ChildAdded:Connect(function(child)
				addParticles(child)
				if child:IsA("ProximityPrompt") then
					self._janitor:Add(child)
	
					self._janitor:Add(child.PromptShown:Connect(function()
						Knit.GetService("DestructibleObjectService"):SetBuildTime(self.Instance)
					end))
	
					self._janitor:Add(child.PromptButtonHoldBegan:Connect(function(player)
						AnimationController:PlayAnimation("Build")
					end))
	
					self._janitor:Add(child.Triggered:Connect(function()
						removeParticles(self.Instance.Interactable:GetChildren())
					end))
	
					self._janitor:Add(child.PromptButtonHoldEnded:Connect(function(player)
						AnimationController:StopAnimation("Build")
					end))
				end
			end))
		end
	end))
end

function DestructibleObjectClient:Stop()
	warn("DestructibleObjectClient stopped")
	self._janitor:Cleanup()
end

return DestructibleObjectClient
