local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local RagdollService = Knit.CreateService({
	Name = "RagdollService",
	Client = {
		RagdollStateChanged = Knit.CreateUnreliableSignal(),
	},
})
--To do change the humanoid state on the client (as the server doesn't owkr)
function RagdollService:KnitStart() end

local function activateVelocity(player)
	-- player.character.HumanoidRootPart.AngularVelocity.Enabled = true
	if player.character:FindFirstChild("LeftUpperLeg") and player.character:FindFirstChild("RightUpperLeg") then
		-- player.character.LeftUpperLeg.AngularVelocity.Enabled = true
		-- player.character.RightUpperLeg.AngularVelocity.Enabled = true
	end
end

local function deactivateVelocity(player)
	player.character.HumanoidRootPart.AngularVelocity.Enabled = false
	player.character.HumanoidRootPart.LinearVelocity.Enabled = false
	if player.character:FindFirstChild("LeftUpperLeg") and player.character:FindFirstChild("RightUpperLeg") then
		player.character.LeftUpperLeg.AngularVelocity.Enabled = false
		player.character.RightUpperLeg.AngularVelocity.Enabled = false
	end
end

function RagdollService:ragdollFreeze(character, state)
	if character and self.ragdollFreezeEnable and state == Enum.HumanoidStateType.Dead then
		local upperTorso = character:WaitForChild("UpperTorso")
		repeat
			local lastPos = upperTorso.Position
			task.wait(self.ragdollFreezeTime.Value) --Time left before it checks body.
			local newPos = upperTorso.Position
			local distanceDiff = (lastPos - newPos).magnitude --print("DistanceDiff", distanceDiff)
		until distanceDiff < 2 --Distance a body must be close from its original check to be anchored

		for i, v in pairs(character:GetChildren()) do
			if v:IsA("MeshPart") then
				v.Anchored = true
			end
		end
		character.HumanoidRootPart.Anchored = true
	end
	if self.currentRagdolls ~= 0 then
		self.currentRagdolls -= 1
	end
end

local function resyncClothes(player)
	for i, v in pairs(player.character:GetChildren()) do --Hack. Refreshes and resyncs layered clothing.
		if v:IsA("Accessory") then
			for i2, v2 in (v.Handle:GetChildren()) do
				if v2:IsA("WrapLayer") then
					local refWT = Instance.new("WrapTarget")
					refWT.Parent = v2.Parent
					refWT:Destroy()
					refWT.Parent = nil
				end
			end
		end
	end
end

local function stopAnims(humanoid)
	local AnimTrack = humanoid:GetPlayingAnimationTracks()
	for i, track in pairs(AnimTrack) do
		track:Stop()
	end
end

local function setLDRagdollState(character: Model, state: boolean)
	if character.UpperTorso then
		for i, motor6d in pairs(character.UpperTorso:GetChildren()) do
			if motor6d:IsA("Motor6D") then
				--motor6d.Parent.CollisionGroupId = 1
				motor6d.Parent.CanTouch = false
				motor6d.Enabled = state
			end
		end
	end

	if character.LeftFoot then
		for i, motor6d in pairs(character.LeftFoot:GetChildren()) do
			if motor6d:IsA("Motor6D") then
				--motor6d.Parent.CollisionGroupId = 1
				motor6d.Parent.CanTouch = false
				motor6d.Enabled = state
			end
		end
	end

	if character.RightFoot then
		for i, motor6d in pairs(character.RightFoot:GetChildren()) do
			if motor6d:IsA("Motor6D") then
				--motor6d.Parent.CollisionGroupId = 1
				motor6d.Parent.CanTouch = false
				motor6d.Enabled = state
			end
		end
	end

	if character.Head then
		for i, motor6d in pairs(character.Head:GetChildren()) do
			if motor6d:IsA("Motor6D") then --Getting motor6D joints as joints. Their parents are the parts.
				--motor6d.Parent.CollisionGroupId = 1
				motor6d.Parent.CanTouch = false
				motor6d.Enabled = state
			end
		end
	end
end

local function setRagdollMotors(character: Model, state: boolean)
	for i, limbs in pairs(character:GetChildren()) do
		for i, child in pairs(limbs:GetChildren()) do
			if child:IsA("Motor6D") then --Getting motor6D joints as joints. Their parents are the parts.
				child.Parent.CollisionGroupId = 1
				child.Enabled = state
			end
		end
	end
end

function RagdollService:RagdollPlayer(player: Player, time: number)
	self.Client.RagdollStateChanged:Fire(player, time)
	activateVelocity(player)
	local character = player.Character
	local humanoid = character.Humanoid
	humanoid:UnequipTools()
	stopAnims(humanoid)
	humanoid.AutoRotate = false
	character.HumanoidRootPart.CollisionGroupId = 1
	character.HumanoidRootPart.CanCollide = false

	if RagdollService.currentRagdolls > RagdollService.ragdollsLdMax then
		lDModeOn = true
	else
		lDModeOn = false
	end

	if RagdollService.deadCharacters >= RagdollService.maxDeadCharacters then
		task.wait(0.1 * RagdollService.deadCharacters) --Activate ragdoll delay, tenth x per character
	end
	if RagdollService.ragdollsLdEnable == true and lDModeOn == true then --If LD mode is on
		setLDRagdollState(character, false)
		if time then
			task.delay(time, function()
				setLDRagdollState(character, true)
				deactivateVelocity(player)
			end)
		end
	else --If LD mode is off
		RagdollService.currentRagdolls += 1
		setRagdollMotors(character, false)
		if time then
			task.delay(time, function()
				setRagdollMotors(character, true)
				deactivateVelocity(player)
			end)
		end
	end

	if time then
		task.delay(time, function()
			--Set the humanoid state back to normal
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

			if RagdollService.ragdollsLdEnable == true and lDModeOn == true then
				setLDRagdollState(character, true)
			else
				setRagdollMotors(character, true)
			end

			deactivateVelocity(player)
		end)
	end
end

function RagdollService.Client:RagdollPlayer(player, character)
	return self.Server:RagdollPlayer(player)
end

function RagdollService:KnitInit()
	self.deadCharacters = 0
	self.currentRagdolls = 0
	self.ragdollsLdMax = 12
	self.maxDeadCharacters = 12
	self.ragdollsLdEnable = true
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")

			humanoid.Died:Connect(function()
				activateVelocity(player)
				humanoid:UnequipTools() --Allow for ragdoll and any tool to sync serverside
				for i, tool in pairs(player.Backpack:GetChildren()) do --If you are looking for :Unequip(), see localscript
					tool:Destroy()
				end
				self.deadCharacters += 1
				stopAnims(humanoid)
				activateVelocity(player)
				self:RagdollPlayer(player)
				resyncClothes(player)
				task.wait() --Without this physics may not activate on platformstand
				deactivateVelocity(player)
				-- self:ragdollFreeze(player.character, humanoid:GetState())
			end)
		end)
	end)
end

return RagdollService
