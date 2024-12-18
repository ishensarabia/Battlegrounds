local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local IsServer = RunService:IsServer()

local gadgetsSystemFolder : Folder = ReplicatedStorage.Source.Systems.GadgetsSystem

local localRandom = Random.new()

local BaseGadget = {}
BaseGadget.__index = BaseGadget

BaseGadget.CanAimDownSights = false
BaseGadget.CanBeReloaded = false
BaseGadget.CanBeFired = false
BaseGadget.CanHit = false

function BaseGadget.new(gadgetSystem : table, instance : Instance)
	warn(gadgetSystem, instance)
	assert(instance, "BaseGadget.new() requires a valid Instance to be attached to.")

	local self = setmetatable({}, BaseGadget)
	self.connections = {}
	self.descendants = {}
	self.descendantsRegistered = false
	self.optionalDescendantNames = {}
	self.gadgetsSystem = gadgetSystem
	self.instance = instance
	self.animController = nil
	self.player = nil
	self.enabled = false
	self.equipped = false
	self.activated = false
	self.nextShotId = 1
	self.activeRenderStepName = nil
	self.curReloadSound = nil

	self.animTracks = {}
	self.sounds = {}
	self.configValues = {}
	self.trackedConfigurations = {}

	self.ammoInWeapon = instance:GetAttribute("CurrentAmmo")

	self.reloading = false
	self.canReload = true

	self:registerDescendants()
	self.connections.descendantAdded = self.instance.DescendantAdded:Connect(function(descendant)
		self:onDescendantAdded(descendant)
	end)

	return self
end

function BaseGadget:doInitialSetup()
	local selfClass = getmetatable(self)
	self.instanceIsTool = self.instance:IsA("Tool")


	-- Initialize gadget ammo values
	if selfClass.CanBeReloaded then
		self.ammoInWeapon = self.instance:GetAttribute("CurrentAmmo") or 0
		self.totalAmmo = self.instance:GetAttribute("TotalAmmo")
	end

	self.connections.ancestryChanged = self.instance.AncestryChanged:Connect(function()
		self:onAncestryChanged()
	end)
	self:onAncestryChanged()

	-- Set up equipped/unequipped and activated/deactivated
	if self.instanceIsTool then
		self.connections.equipped = self.instance.Equipped:Connect(function()
			if
				IsServer
				or (
					Players.LocalPlayer
					and (
						self.instance:IsDescendantOf(Players.LocalPlayer.Backpack)
						or self.instance:IsDescendantOf(Players.LocalPlayer.Character)
					)
				)
			then
				self:setEquipped(true)
				if self:getAmmoInWeapon() <= 0 then
					-- Have to wait a frame, otherwise the reload animation will not play
					coroutine.wrap(function()
						task.wait()
						self:reload()
					end)()
				end
			end
		end)
		self.connections.unequipped = self.instance.Unequipped:Connect(function()
			if
				IsServer
				or (
					Players.LocalPlayer
					and (
						self.instance:IsDescendantOf(Players.LocalPlayer.Backpack)
						or self.instance:IsDescendantOf(Players.LocalPlayer.Character)
					)
				)
			then
				self:setEquipped(false)
				if self.reloading then
					self:cancelReload()
				end
			end
		end)
		if self.instance:IsDescendantOf(workspace) and self.player then
			self:setEquipped(true)
		end

		self.connections.activated = self.instance.Activated:Connect(function()
			self:setActivated(true)
		end)
		self.connections.deactivated = self.instance.Deactivated:Connect(function()
			self:setActivated(false)
		end)

		-- Weld handle to gadget primary part
		if IsServer then
			self.handle = self.instance:FindFirstChild("Handle")
			
			local model = self.instance:FindFirstChildOfClass("Model")
			local handleAttachment = model:FindFirstChild("HandleAttachment", true)
			
			if self.handle and handleAttachment then
				warn("Welding handle to primary part")
				local handleOffset = model.PrimaryPart.CFrame:toObjectSpace(handleAttachment.WorldCFrame)

				local weld = Instance.new("Weld")
				weld.Name = "HandleWeld"
				weld.Part0 = self.handle
				weld.Part1 = model.PrimaryPart
				weld.C0 = CFrame.new()
				weld.C1 = handleOffset
				weld.Parent = self.handle

				self.handle.Anchored = false
				model.PrimaryPart.Anchored = false
			end
		end
	end
end

function BaseGadget:registerDescendants()
	if not self.instance then
		error("No instance set yet!")
	end

	if self.descendantsRegistered then
		warn("Descendants already registered!")
		return
	end

	for _, descendant in ipairs(self.instance:GetDescendants()) do
		if self.descendants[descendant.Name] == nil then
			self.descendants[descendant.Name] = descendant
		else
			self.descendants[descendant.Name] = "Multiple"
		end
	end
	self.descendantsRegistered = true
end

function BaseGadget:addOptionalDescendant(key, descendantName)
	if self.instance == nil then
		error("No instance set yet!")
	end

	if not self.descendantsRegistered then
		error("Descendants not registered!")
	end

	if self.descendants[descendantName] == "Multiple" then
		error(
			'gadget "'
				.. self.instance.Name
				.. '" has multiple descendants named "'
				.. descendantName
				.. '", so you cannot addOptionalDescendant with that descendant name.'
		)
	end

	local found = self.descendants[descendantName]
	if found then
		self[key] = found
		return
	else
		self.optionalDescendantNames[descendantName] = key
	end
end

function BaseGadget:onDescendantAdded(descendant)
	if self.descendants[descendant.Name] == nil then
		self.descendants[descendant.Name] = descendant
	else
		self.descendants[descendant.Name] = "Multiple"
	end

	local desiredKey = self.optionalDescendantNames[descendant.Name]
	if desiredKey then
		if self.descendants[descendant.Name] == "Multiple" then
			error(
				'gadget "'
					.. self.instance.Name
					.. '" has multiple descendants named "'
					.. descendant.Name
					.. '", so you cannot addOptionalDependency with that descendant name.'
			)
		end
		self[desiredKey] = descendant
		self.optionalDescendantNames[descendant.Name] = nil
	end
end

function BaseGadget:cleanupConnection(...)
	local args = { ... }
	for _, name in pairs(args) do
		if typeof(name) == "string" and self.connections[name] then
			self.connections[name]:Disconnect()
			self.connections[name] = nil
		end
	end
end

function BaseGadget:onAncestryChanged()
	if self.instanceIsTool then
		local player = nil
		if self.instance:IsDescendantOf(Players) then
			local parentPlayer = self.instance.Parent.Parent
			if parentPlayer and parentPlayer:IsA("Player") then
				player = parentPlayer
			end
		elseif self.instance:IsDescendantOf(workspace) then
			local parentPlayer = Players:GetPlayerFromCharacter(self.instance.Parent)
			if parentPlayer and parentPlayer:IsA("Player") then
				player = parentPlayer
			end
		end

		self:setPlayer(player)
	end
end

function BaseGadget:setPlayer(player)
	if self.player == player then
		return
	end

	self.player = player
end

function BaseGadget:setEquipped(equipped)
	if self.equipped == equipped then
		return
	end

	self.equipped = equipped
	self:onEquippedChanged()

	if not self.equipped then
		self:stopAnimations()
	end
end

function BaseGadget:onEquippedChanged()
	local WeaponService = Knit.GetService("WeaponsService")

	if self.activeRenderStepName then
		RunService:UnbindFromRenderStep(self.activeRenderStepName)
		self.activeRenderStepName = nil
	end
	self:cleanupConnection("localStepped")

	if not IsServer and self.gadgetsSystem then
		self.gadgetsSystem.setGadgetEquipped(self, self.equipped)
		if self.equipped then
			if self.player == Players.LocalPlayer then
				RunService:BindToRenderStep(self.instance:GetFullName(), Enum.RenderPriority.Input.Value, function(dt)
					self:onRenderStepped(dt)
				end)
				self.activeRenderStepName = self.instance:GetFullName()
			end
			self.connections.localStepped = RunService.Heartbeat:Connect(function(dt)
				self:onStepped(dt)
			end)
		end
	end

	if self.instanceIsTool then
		for _, part in (self.instance:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = part ~= self.handle and not self.equipped
			end
		end
	end

	-- if IsServer and self.equipped then
	-- 	WeaponService:SetIKForWeapon(self.player, self.instance)
	-- end

	-- if IsServer and not self.equipped then
	-- 	WeaponService:CleanupIKForWeapon(self.player)
	-- end
	self:setActivated(false)
end

function BaseGadget:setActivated(activated, fromNetwork)
	if not IsServer and fromNetwork and self.player == Players.LocalPlayer then
		return
	end

	if self.activated == activated then
		return
	end

	self.activated = activated
	if IsServer and not fromNetwork then
		self.gadgetsSystem.getRemoteEvent("WeaponActivated"):FireAllClients(self.player, self.instance, self.activated)
	end

	self:onActivatedChanged()
end

function BaseGadget:onActivatedChanged() end

function BaseGadget:renderFire(fireInfo) end

function BaseGadget:simulateFire(fireInfo) end

function BaseGadget:isOwnerAlive()
	if self.instance:IsA("Tool") then
		local humanoid = self.instance.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid then
			return humanoid:GetState() ~= Enum.HumanoidStateType.Dead
		end
	end

	return true
end

function BaseGadget:fire(origin, dir, charge)
	if not self:isOwnerAlive() or self.reloading then
		return
	end

	if self:useAmmo(1) <= 0 then
		self:reload()
		return
	end

	local fireInfo = {}
	fireInfo.origin = origin
	fireInfo.dir = dir
	fireInfo.charge = math.clamp(charge or 1, 0, 1)
	fireInfo.id = self.nextShotId
	self.nextShotId = self.nextShotId + 1

	if not IsServer then
		self:onFired(self.player, fireInfo, false)
		self.gadgetsSystem.getRemoteEvent("WeaponFired"):FireServer(self.instance, fireInfo)
	else
		self:onFired(self.player, fireInfo, false)
	end
end

function BaseGadget:onFired(firingPlayer, fireInfo, fromNetwork)
	if not IsServer then
		if firingPlayer == Players.LocalPlayer and fromNetwork then
			return
		end

		self:simulateFire(firingPlayer, fireInfo)
	else
		if self:useAmmo(1) <= 0 then
			return
		end

		self.gadgetsSystem.getRemoteEvent("WeaponFired"):FireAllClients(firingPlayer, self.instance, fireInfo)
	end
end

function BaseGadget:getConfigValue(valueName, defaultValue)
	if self.configValues[valueName] ~= nil then
		return self.configValues[valueName]
	else
		return defaultValue
	end
end

function BaseGadget:tryPlaySound(soundName, playbackSpeedRange)
	playbackSpeedRange = playbackSpeedRange or 0

	local soundTemplate = self.sounds[soundName]
	if not soundTemplate then
		soundTemplate = self.instance:FindFirstChild(soundName, true)
		self.sounds[soundName] = soundTemplate
	end

	if not soundTemplate then
		return
	end

	local sound = soundTemplate:Clone()
	sound.PlaybackSpeed = sound.PlaybackSpeed
		+ localRandom:NextNumber(-playbackSpeedRange * 0.5, playbackSpeedRange * 0.5)
	sound.Parent = soundTemplate.Parent
	sound:Play()
	coroutine.wrap(function()
		task.wait(sound.TimeLength / sound.PlaybackSpeed)
		sound:Destroy()
	end)()

	return sound
end

function BaseGadget:getSound(soundName)
	local soundTemplate = self.sounds[soundName]
	if not soundTemplate then
		soundTemplate = self.instance:FindFirstChild(soundName, true)
		self.sounds[soundName] = soundTemplate
	end

	return soundTemplate
end

function BaseGadget:onDestroyed() end

function BaseGadget:onConfigValueAdded(valueObj)
	local valueName = valueObj.Name
	local newValue = valueObj.Value
	self.configValues[valueName] = newValue
	self:onConfigValueChanged(valueName, newValue, nil)

	self.connections["valueChanged:" .. valueName] = valueObj.Changed:Connect(function(changedValue)
		local oldValue = self.configValues[valueName]
		self.configValues[valueName] = changedValue

		self:onConfigValueChanged(valueName, changedValue, oldValue)
	end)
	self.connections["valueRenamed:" .. valueName] = valueObj:GetPropertyChangedSignal("Name"):Connect(function()
		self.configValues[valueName] = nil
		self:cleanupConnection("valueChanged:" .. valueName)
		self:cleanupConnection("valueRenamed:" .. valueName)
		self:onConfigValueAdded(valueObj)
	end)
end

function BaseGadget:addConfigAttribute(name: string, attribute: any)
	self.configValues[name] = attribute
end

function BaseGadget:onConfigValueRemoved(valueObj)
	local valueName = valueObj.Name
	self.configValues[valueName] = nil

	self:cleanupConnection("valueChanged:" .. valueName)
	self:cleanupConnection("valueRenamed:" .. valueName)
end

-- This function is used to set configuration values from outside configuration objects/folders
function BaseGadget:importConfiguration(config)
	if not config or not config:IsA("Configuration") then
		for _, child in pairs(config:GetChildren()) do
			if child:IsA("ValueBase") then
				local valueName = child.Name
				local newValue = child.Value
				local oldValue = self.configValues[valueName]
				self.configValues[valueName] = newValue
				self:onConfigValueChanged(valueName, newValue, oldValue)
			end
		end
	end
end

function BaseGadget:setConfiguration(config)
	self:cleanupConnection("configChildAdded", "configChildRemoved")
	if not config or not config:IsA("Configuration") then
		return
	end

	for _, child in pairs(config:GetChildren()) do
		if child:IsA("ValueBase") then
			self:onConfigValueAdded(child)
		end
	end

	self.connections.configChildAdded = config.ChildAdded:Connect(function(child)
		if child:IsA("ValueBase") then
			self:onConfigValueAdded(child)
		end
	end)
	self.connections.configChildRemoved = config.ChildRemoved:Connect(function(child)
		if child:IsA("ValueBase") then
			self:onConfigValueRemoved(child)
		end
	end)
end

function BaseGadget:onChildAdded(child)
	if child:IsA("Configuration") then
		self:setConfiguration(child)
	end
end

function BaseGadget:onChildRemoved(child)
	if child:IsA("Configuration") then
		self:setConfiguration(nil)
	end
end

function BaseGadget:onConfigValueChanged(valueName, newValue, oldValue) end

function BaseGadget:onRenderStepped(dt) end

function BaseGadget:onStepped(dt) end

function BaseGadget:getAnimationController()
	if self.animController then
		if
			not self.instanceIsTool
			or (self.animController.Parent and self.animController.Parent:IsAncestorOf(self.instance))
		then
			return self.animController
		end
	end

	self:setAnimationController(nil)

	if self.instanceIsTool then
		local humanoid = IsServer and self.instance.Parent:FindFirstChildOfClass("Humanoid")
			or self.instance.Parent:WaitForChild("Humanoid", math.huge)
		local animController = nil
		if not humanoid then
			animController = self.instance.Parent:FindFirstChildOfClass("AnimationController")
		end

		self:setAnimationController(humanoid or animController)
		return self.animController
	end
end

function BaseGadget:setAnimationController(animController)
	if animController == self.animController then
		return
	end
	self:stopAnimations()
	self.animController = animController
end

function BaseGadget:stopAnimations()
	for _, track in pairs(self.animTracks) do
		if track.IsPlaying then
			track:Stop()
		end
	end
	self.animTracks = {}
end

function BaseGadget:getAnimTrack(key)
	-- local track = self.animTracks[key]
	-- if not track then
	-- 	local animController = self:getAnimationController()
	-- 	if not animController then
	-- 		warn("No animation controller when trying to play ", key)
	-- 		return nil
	-- 	end

	-- 	local animation = AnimationsFolder:FindFirstChild(key)
	-- 	if not animation then
	-- 		error(string.format('No such animation "%s" ', tostring(key)))
	-- 	end

	-- 	track = animController:LoadAnimation(animation)
	-- 	self.animTracks[key] = track
	-- end

	return track
end

function BaseGadget:reload(player, fromNetwork)
	if
		not self.equipped
		or self.reloading
		or not self.canReload
		or self:getAmmoInWeapon() == self.instance:GetAttribute("AmmoCapacity")
		or self:getTotalAmmo() <= 0
	then
		return false
	end

	if not IsServer then
		if self.player ~= nil and self.player ~= Players.LocalPlayer then
			return
		end
		self.gadgetsSystem.getRemoteEvent("WeaponReloadRequest"):FireServer(self.instance)
		self:onReloaded(self.player)
	else
		self:onReloaded(player, fromNetwork)
		self.gadgetsSystem.getRemoteEvent("WeaponReloaded"):FireAllClients(player, self.instance)
	end
end

function BaseGadget:onReloaded(player, fromNetwork)
	if fromNetwork and player == Players.LocalPlayer then -- make sure localplayer doesn't reload twice
		return
	end

	self.reloading = true
	self.canReload = false

	-- Play reload animation and sound
	if not IsServer then
		local reloadTrackKey = self:getConfigValue("ReloadAnimation", "RifleReload")
		if reloadTrackKey then
			self.reloadTrack = self:getAnimTrack(reloadTrackKey)
			if self.reloadTrack then
				player.Character.Humanoid.SecondHandleIK.Enabled = false
				self.reloadTrack:Play()
				self.reloadTrack.Stopped:Connect(function()
					player.Character.Humanoid.SecondHandleIK.Enabled = true
				end)
			end
		end

		self.curReloadSound = self:tryPlaySound("Reload", nil)
		if self.curReloadSound then
			self.curReloadSound.Ended:Connect(function()
				self.curReloadSound = nil
			end)
		end
	end

	local reloadTime = self:getConfigValue("ReloadTime", 2)
	local startTime = tick()

	if self.connections.reload ~= nil then -- this prevents an endless ammo bug
		return
	end
	self.connections.reload = RunService.Heartbeat:Connect(function()
		-- Stop trying to reload if the player unequipped this gadget or reloading was canceled some other way
		if not self.reloading then
			if self.connections.reload then
				self.connections.reload:Disconnect()
				self.connections.reload = nil
			end
		end

		-- Wait until gun finishes reloading
		if tick() < startTime + reloadTime then
			return
		end

		-- Calculate ammo needed for reload
		local ammoNeeded = self.instance:GetAttribute("AmmoCapacity") - self.instance:GetAttribute("CurrentAmmo")

		-- Check if there's enough ammo to reload
		if self.instance:GetAttribute("TotalAmmo") >= ammoNeeded then
			-- Add ammo to gadget
			self.instance:SetAttribute("CurrentAmmo", self.instance:GetAttribute("AmmoCapacity"))

			-- Reduce total ammo
			self.instance:SetAttribute("TotalAmmo", self.instance:GetAttribute("TotalAmmo") - ammoNeeded)
		else
			-- If not enough total ammo, reload only the total ammo left
			local totalAmmoLeft = self.instance:GetAttribute("TotalAmmo")
			self.instance:SetAttribute("CurrentAmmo", self.instance:GetAttribute("CurrentAmmo") + totalAmmoLeft)

			-- Set total ammo to 0
			self.instance:SetAttribute("TotalAmmo", 0)
		end

		if self.connections.reload then
			self.connections.reload:Disconnect()
			self.connections.reload = nil
		end

		self.reloading = false
		self.canReload = false
	end)
end

function BaseGadget:cancelReload(player, fromNetwork)
	if not self.reloading then
		return
	end
	if fromNetwork and player == Players.LocalPlayer then
		return
	end

	if not IsServer and not fromNetwork and player == Players.LocalPlayer then
		self.gadgetsSystem.getRemoteEvent("WeaponReloadCanceled"):FireServer(self.instance)
	elseif IsServer and fromNetwork then
		self.gadgetsSystem.getRemoteEvent("WeaponReloadCanceled"):FireAllClients(player, self.instance)
	end

	self.reloading = false
	self.canReload = true

	if not IsServer and self.reloadTrack and self.reloadTrack.IsPlaying then
		warn("Stopping reloadTrack")
		self.reloadTrack:Stop()
	end
	if self.curReloadSound then
		self.curReloadSound:Stop()
		self.curReloadSound:Destroy()
		self.curReloadSound = nil
	end
end

function BaseGadget:getAmmoInWeapon()
	if self.instance:GetAttribute("CurrentAmmo") then
		return self.instance:GetAttribute("CurrentAmmo")
	else
		warn("No CurrentAmmo attribute found for gadget ", self.instance.Name)
	end
end

function BaseGadget:getTotalAmmo()
	if self.instance:GetAttribute("TotalAmmo") then
		return self.instance:GetAttribute("TotalAmmo")
	else
		warn("No TotalAmmo attribute found for gadget ", self.instance.Name)
	end
end

function BaseGadget:useAmmo(amount)
	local ammoUsed = math.min(amount, self.instance:GetAttribute("CurrentAmmo"))
	self.instance:SetAttribute("CurrentAmmo", self.instance:GetAttribute("CurrentAmmo") - ammoUsed)
	self.canReload = true
	return ammoUsed
end

function BaseGadget:renderCharge() end

return BaseGadget
