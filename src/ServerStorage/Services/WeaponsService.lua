local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Dependencies
local WeaponsSystem = require(ReplicatedStorage.Source.Systems.WeaponsSystem.WeaponsSystem)
local weaponsSystemFolder = ReplicatedStorage.Source.Systems.WeaponsSystem
local weaponsSystemInitialized = false

local WeaponsService = Knit.CreateService({
	Name = "WeaponsService",
	Client = {
		SendWeaponData = Knit.CreateSignal(),
	},
})

local function initializeWeaponsSystemAssets()
	if not weaponsSystemInitialized then
		-- Enable/make visible all necessary assets
		local effectsFolder = ReplicatedStorage.Assets.Effects
		local partNonZeroTransparencyValues = {
			["BulletHole"] = 1,
			["Explosion"] = 1,
			["Pellet"] = 1,
			["Scorch"] = 1,
			["Bullet"] = 1,
			["Plasma"] = 1,
			["Railgun"] = 1,
		}
		local decalNonZeroTransparencyValues = { ["ScorchMark"] = 0.25 }
		local particleEmittersToDisable = { ["Smoke"] = true }
		local imageLabelNonZeroTransparencyValues = { ["Impact"] = 0.25 }
		for _, descendant in pairs(effectsFolder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				if partNonZeroTransparencyValues[descendant.Name] ~= nil then
					descendant.Transparency = partNonZeroTransparencyValues[descendant.Name]
				else
					descendant.Transparency = 0
				end
			elseif descendant:IsA("Decal") then
				descendant.Transparency = 0
				if decalNonZeroTransparencyValues[descendant.Name] ~= nil then
					descendant.Transparency = decalNonZeroTransparencyValues[descendant.Name]
				else
					descendant.Transparency = 0
				end
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
				if particleEmittersToDisable[descendant.Name] ~= nil then
					descendant.Enabled = false
				else
					descendant.Enabled = true
				end
			elseif descendant:IsA("ImageLabel") then
				if imageLabelNonZeroTransparencyValues[descendant.Name] ~= nil then
					descendant.ImageTransparency = imageLabelNonZeroTransparencyValues[descendant.Name]
				else
					descendant.ImageTransparency = 0
				end
			end
		end

		weaponsSystemInitialized = true
	end
end

function WeaponsService:KnitStart()
	initializeWeaponsSystemAssets()
	if not WeaponsSystem.doingSetup and not WeaponsSystem.didSetup then
		WeaponsSystem.setup()
	end
end

function WeaponsService:GetCategoryWeaponsForPlayer(category: string, player: Player) end

function WeaponsService:SendWeaponData(targetPlayer: Player, typeOfData: string, dealerPosition: Vector3)
	self.Client.SendWeaponData:Fire(targetPlayer, tyyopeOfData, dealerPosition)
end

function WeaponsService:SetIKForWeapon(player, instance: Instance)
	--Animate the selected weapon
	if not self.IKSessions[player.UserId] and instance.Handle:FindFirstChild("SecondHandleAttachment") then
		warn("Setting weapon IK for weapon : " .. instance.Name .. " for player: " .. player.Name)
		local IKController = Instance.new("IKControl")
		IKController.Name = "SecondHandleIK"
		self.IKSessions[player.UserId] = IKController
		IKController.Parent = player.Character.Humanoid
		IKController.ChainRoot = player.Character.LeftUpperArm
		IKController.EndEffector = player.Character.LeftHand
		IKController.Target = instance.Handle.SecondHandleAttachment
		IKController.Pole = instance.Handle.SecondHandleAttachment

		-- Add hinge constraint
		local hingeConstraint = Instance.new("HingeConstraint")
		hingeConstraint.Name = "ElbowHingeConstraint"
		hingeConstraint.Parent = player.Character.LeftLowerArm
		hingeConstraint.Attachment0 = Instance.new("Attachment", player.Character.LeftUpperArm)
		hingeConstraint.Attachment1 = Instance.new("Attachment", player.Character.LeftLowerArm)
		hingeConstraint.LimitsEnabled = true
		hingeConstraint.UpperAngle = 120
		hingeConstraint.LowerAngle = 0
		hingeConstraint.Restitution = 0.5
		hingeConstraint.ActuatorType = Enum.ActuatorType.Motor
	end
end

function WeaponsService:SetIKState(player, state: boolean)
	if self.IKSessions[player.UserId] then
		self.IKSessions[player.UserId].Enabled = state
	end
end

function WeaponsService.Client:SetIKState(player, state: boolean)
	return self.Server:SetIKState(player, state)
end

function WeaponsService:CleanupIKForWeapon(player)
	if self.IKSessions[player.UserId] then
		self.IKSessions[player.UserId]:Destroy()
		self.IKSessions[player.UserId] = nil
	end
end

function WeaponsService:KnitInit()
	self.IKSessions = {}
end

return WeaponsService
