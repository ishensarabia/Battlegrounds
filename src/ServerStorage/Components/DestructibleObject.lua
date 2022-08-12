local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Component = require(game.ReplicatedStorage.Packages.Component)
local TweenObject = require(game.ServerStorage.Source.Systems.TweenObject)
local Players = game:GetService("Players")
--Services
local TweenService = game:GetService("TweenService")

local DestructibleObject = Component.new({
	Tag = "DestructibleObject",
})

function DestructibleObject:Construct()
	self.isConstructed = true
	self.isBeingConstructed = false
	self._janitor = Janitor.new()
	self._constructorID = 0
	self._partsCFrames = {}
	self._tweenPromises = {}
	self._handsTweenPromises = {}
	self.constructPrompt = nil
	self.constructPrompts = {}
	self._shouldAnchor = self.Instance:GetAttribute("ShouldAnchor") or true
end

function DestructibleObject:DestroyObject()
	--Make sure the object is constructed before destroying it
	if not self.isConstructed then
		return
	end
	--Setup proximity prompts
	for index, child in pairs(self.Instance.Interactable:GetChildren()) do
		if child:IsA("BasePart") then
			local constructPrompt = child.Attachment:FindFirstChild("ProximityPrompt")
				or Instance.new("ProximityPrompt")
			constructPrompt.Parent = child.Attachment
			constructPrompt.RequiresLineOfSight = false
			constructPrompt.ActionText = "Build"
			table.insert(self.constructPrompts, constructPrompt)
			self._janitor:Add(constructPrompt)

			self._janitor:Add(constructPrompt.PromptButtonHoldBegan:Connect(function(player)
				player.Character.Humanoid:UnequipTools()
				self:ConstructObject(player)
			end))

			self._janitor:Add(constructPrompt.Triggered:Connect(function(player)
				self.isConstructed = true
				self:ConstructObject(player)
				self._janitor:Cleanup()
			end))

			self._janitor:Add(constructPrompt.PromptButtonHoldEnded:Connect(function(player)
				-- if (not self.isConstructed) then
				self:CancelConstruction()
				-- end
			end))
		end
	end

	for key, child in pairs(self.Instance:GetChildren()) do
		if child:IsA("BasePart") then
			child.Anchored = false
		end
	end
	
	self:_setBuildTime()
	self.isConstructed = false
end

function DestructibleObject:Start()
	self:_setModelPartCFrames()
end

function DestructibleObject:_setModelPartCFrames()
	for index, child in pairs(self.Instance:GetChildren()) do
		if child:IsA("BasePart") then
			if child:GetAttribute("PartIndex") then
				self._partsCFrames[child:GetAttribute("PartIndex")] = child.CFrame
			else
				error("No index part was set for the parts of the model")
			end
		end
	end
end

function DestructibleObject:_setBuildPromptTime()
	local promptTime = 0
	for index, child in pairs(self.Instance:GetChildren()) do
		if child:IsA("BasePart") then
			local magnitude =
				(child.CFrame.Position - self._partsCFrames[child:GetAttribute("PartIndex")].Position).Magnitude
			if magnitude > 13 then
				local length = #self.Instance:GetChildren() / index / #self.Instance:GetChildren()
				promptTime += length
			end
		end
	end
	if promptTime < 1 then
		promptTime = 1
	end
	return promptTime
end

function DestructibleObject:_setBuildTime()
	for index, constructPrompt in ipairs(self.constructPrompts) do
		constructPrompt.HoldDuration = self:_setBuildPromptTime()
	end
end

function DestructibleObject:ConstructObject(player)
	--Make sure it isn't being constructed
	if self.isBeingConstructed then
		return
	end
	local buildTime = 0
	self.isBeingConstructed = true
	for index, child in pairs(self.Instance:GetChildren()) do
		if child:IsA("BasePart") then
			local magnitude =
				(child.CFrame.Position - self._partsCFrames[child:GetAttribute("PartIndex")].Position).Magnitude
			if magnitude > 25 then
				local length = #self.Instance:GetChildren() / index / #self.Instance:GetChildren()
				buildTime += length
			end
			if buildTime < 1 then
				buildTime = 1
			end
			if self.isConstructed then
				local promise = TweenObject.TweenBasePart(
					child,
					TweenInfo.new(buildTime - 0.35),
					{ CFrame = self._partsCFrames[child:GetAttribute("PartIndex")] }
				)
				self._tweenPromises[child:GetAttribute("PartIndex")] = promise
			else
				if magnitude > 5 then
                    child.CanCollide = false
					local handPromise = TweenObject.TweenBasePart(
						child,
						TweenInfo.new(buildTime),
						{
							CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(
								0,
								0,
								math.random(-9, -3)
							),
						}
					)
					self._handsTweenPromises[child:GetAttribute("PartIndex")] = handPromise
					handPromise:andThen(function()
						local promise = TweenObject.TweenBasePart(
							child,
							TweenInfo.new(buildTime - 0.5),
							{ CFrame = self._partsCFrames[child:GetAttribute("PartIndex")] }
						)
						self._tweenPromises[child:GetAttribute("PartIndex")] = promise
					end)
				end
			end
			--Cleanup part
			child.Anchored = self._shouldAnchor
			child.AssemblyLinearVelocity = Vector3.new(0,0,0)
			child.AssemblyAngularVelocity = Vector3.new(0,0,0)
		end
	end

	for key, child in pairs(self.Instance:GetChildren()) do
		if child:IsA("BasePart") then
			child.CanCollide = true
		end
	end
end

function DestructibleObject:CancelConstruction()
	self.isBeingConstructed = false
	for key, child in pairs(self.Instance:GetChildren()) do
		if child:IsA("BasePart") then
			child.Anchored = false
			child.CanCollide = true
			if self._tweenPromises[child:GetAttribute("PartIndex")] then
				self._tweenPromises[child:GetAttribute("PartIndex")]:cancel()
			end
			if self._handsTweenPromises[child:GetAttribute("PartIndex")] then
				self._handsTweenPromises[child:GetAttribute("PartIndex")]:cancel()
			end
		end
	end
end

function DestructibleObject:Stop() end

return DestructibleObject
