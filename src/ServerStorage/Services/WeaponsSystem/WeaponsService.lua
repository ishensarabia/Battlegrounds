local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Dependencies
local WeaponsSystem = require(ReplicatedStorage.Source.Systems.WeaponsSystem.WeaponsSystem)
local weaponsSystemFolder = ReplicatedStorage.Source.Systems.WeaponsSystem
local weaponsSystemInitialized = false

local WeaponsService = Knit.CreateService {
    Name = "WeaponsService",
    Client = 
	{
		SendWeaponData = Knit.CreateSignal()
	},
}

local function initializeWeaponsSystemAssets()
	if not weaponsSystemInitialized then
		-- Enable/make visible all necessary assets
		local effectsFolder = weaponsSystemFolder.Assets.Effects
		local partNonZeroTransparencyValues = {
			["BulletHole"] = 1, ["Explosion"] = 1, ["Pellet"] = 1, ["Scorch"] = 1,
			["Bullet"] = 1, ["Plasma"] = 1, ["Railgun"] = 1,
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
	if (not WeaponsSystem.doingSetup and not WeaponsSystem.didSetup) then
		WeaponsSystem.setup()
	end
end

function WeaponsService:SendWeaponData(targetPlayer : Player, typeOfData : string, dealerPosition : Vector3)
	self.Client.SendWeaponData:Fire(targetPlayer, typeOfData, dealerPosition)
end

function WeaponsService:KnitInit()
end


return WeaponsService
