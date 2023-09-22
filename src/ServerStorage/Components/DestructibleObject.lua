local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Component = require(game.ReplicatedStorage.Packages.Component)
local TweenObject = require(ReplicatedStorage.Source.Modules.Util.TweenObject)
local Players = game:GetService("Players")
--Services
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local movementThreshold = 6.33
--Module dependencies
--Class
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
end

function DestructibleObject:DestroyObject(player)
	--Make sure the object is constructed before destroying it
	if not self.isConstructed then
		return
	end
	warn("Object : " .. self.Instance.Name .. " has been destroyed")
	self.isConstructed = false
	local DataService = Knit.GetService("DataService")
	if player then
		DataService:incrementIntValue(player, "DestroyedObjects")
		Knit.GetService("ChallengesService"):UpdateChallengeProgression(player, "DestroyObjects", 1)
	end
	--Setup proximity prompts
	if self.Instance:FindFirstChild("Interactable") then
		for index, child in pairs(self.Instance.Interactable:GetChildren()) do
			if child:IsA("BasePart") then
				local constructPrompt = Instance.new("ProximityPrompt")
				constructPrompt.Parent = child.Attachment
				constructPrompt.RequiresLineOfSight = false
				constructPrompt.ActionText = "Build"
				warn("created attachment" .. constructPrompt.Name)
				table.insert(self.constructPrompts, constructPrompt)
				self._janitor:Add(constructPrompt)

				self._janitor:Add(constructPrompt.PromptButtonHoldBegan:Connect(function(player)
					player.Character.Humanoid:UnequipTools()
					self:ConstructObject(player)
				end))

				self._janitor:Add(constructPrompt.Triggered:Connect(function(player)
					player.Character.Humanoid:UnequipTools()
					self._janitor:Cleanup()
					self.isConstructed = true
					self:ConstructObject(player)
					--Make sure it's a successful build by checking after 1.33 seconds
					task.delay(1.33, function()
						if self.isConstructed then
							warn("Challenge progression")
							Knit.GetService("ChallengesService"):UpdateChallengeProgression(player, "BuildObjects", 1)
						end
					end)
				end))

				self._janitor:Add(constructPrompt.PromptButtonHoldEnded:Connect(function(player)
					-- if (not self.isConstructed) then
					self:CancelConstruction()
					-- end
				end))
			end
		end

		self:_setBuildTime()
	end
	warn("Destroying object")
	for key, child in pairs(self.Instance:GetChildren()) do
		if child:IsA("BasePart") then
			child.Anchored = false
		end
	end
end

function DestructibleObject:Start()
	if self.Instance:FindFirstChild("Interactable") then		
		self:_setModelPartCFrames()
	end
	--Check for the object parts changed attribute, if it changes then destroy the object as it is not anchored correctly
	if self.Instance:FindFirstChild("Interactable") then		
		for index, child in (self.Instance:GetChildren()) do
			if child:IsA("BasePart") then
				child.Touched:Connect(function()
					if self.isBeingConstructed then
						warn("Is being constructed")
						return
					end
					local part = child
					local previousPosition = self._partsCFrames[part:GetAttribute("PartIndex")].Position
	
					local movementMagnitude = (part.Position - previousPosition).Magnitude
	
					if movementMagnitude > movementThreshold and not self.isBeingConstructed and self.isConstructed then
						warn("Destoying object because of movement for object : " .. self.Instance.Name)
						self:DestroyObject()
					end
				end)
			end
		end
	end
end
--Make sure the destructible object gets done in the right
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
			local magnitude = (child.CFrame.Position - self._partsCFrames[child:GetAttribute("PartIndex")].Position).Magnitude
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
			local magnitude = (child.CFrame.Position - self._partsCFrames[child:GetAttribute("PartIndex")].Position).Magnitude
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
					local handPromise = TweenObject.TweenBasePart(child, TweenInfo.new(buildTime), {
						CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, math.random(-9, -3)),
					})
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
			local shouldAnchor = self.Instance:GetAttribute("ShouldAnchor")
			if shouldAnchor == false then
				child.Anchored = false
			elseif shouldAnchor == nil then
				child.Anchored = true
			end
			child.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			child.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end
	end

	if self.isConstructed then
		for key, child in (self.Instance:GetChildren()) do
			if child:IsA("BasePart") then
				child.CanCollide = true
			end
		end
	end

	self.isBeingConstructed = false
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

function DestructibleObject:Stop()
	self._janitor:Cleanup()
end

return DestructibleObject
