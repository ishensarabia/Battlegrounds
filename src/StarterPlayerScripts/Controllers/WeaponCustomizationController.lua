local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)
--Main controller
local WeaponCustomizationController = Knit.CreateController({ Name = "WeaponCustomizationController" })
--Constants
local TEXTURE_SPEED = 1_000
local TWEEN_INFO = TweenInfo.new(TEXTURE_SPEED, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0)
function WeaponCustomizationController:KnitStart()
	--services
	self._dataService = Knit.GetService("DataService")
	self._janitor = Janitor.new()
	self._textureTweens = {}
end

function WeaponCustomizationController:AnimateWeaponSkin(weaponModel)
	--Get weapon parts to apply the skin
	for index, value in weaponModel:GetDescendants() do
		if value:IsA("Texture") then
			local textureTween = TweenService:Create(value, TWEEN_INFO, {
				OffsetStudsU = 30,
				OffsetStudsV = 30
			})
			textureTween:Play()
			self._janitor:Add(textureTween)
		end
	end
end

function WeaponCustomizationController:AnimateWeaponSkinPart(part)
	for index, child in (part:GetChildren()) do
		if child:IsA("Texture") then
			local textureTween = TweenService:Create(child, TWEEN_INFO, {
				OffsetStudsU = 30,
				OffsetStudsV = 30
			})
			textureTween:Play()
			self._textureTweens[child] = textureTween
			self._janitor:Add(textureTween)
		end
	end
end

function WeaponCustomizationController:ApplySkinForPreview(weaponModel, skinData: table)
	--Get weapon parts to apply the skin
	for index, value in weaponModel:GetDescendants() do
		if value:GetAttribute("CustomPart") then
			local textures = {}
			--It's a texture
			for i = 1, 6, 1 do
				local texture = Instance.new("Texture")
				texture.Name = "Skin"
				texture.Texture = skinData.skinID
				texture.StudsPerTileU = 0.2
				texture.StudsPerTileV = 0.3
				table.insert(textures, texture)
				texture.Parent = value
			end
			textures[1].Face = Enum.NormalId.Back
			textures[2].Face = Enum.NormalId.Bottom
			textures[3].Face = Enum.NormalId.Front
			textures[4].Face = Enum.NormalId.Left
			textures[5].Face = Enum.NormalId.Right
			textures[6].Face = Enum.NormalId.Top
		end
	end
	if skinData.shouldAnimate then
		self:AnimateWeaponSkin(weaponModel)
	end
end

function WeaponCustomizationController:CleanUpSkinAnimationForPart(part)
	for index, child in (part:GetChildren()) do
		if child:IsA("Texture") then
			warn("cleaning up skin animation")
			if self._textureTweens[child] then
				self._textureTweens[child]:Cancel()
			end
			self._janitor:Remove(self._textureTweens[child])
		end
	end
end

function WeaponCustomizationController:CreateWeaponPreviewWithSkin(weaponID: string, skinData: table)
	local weaponModel = ReplicatedStorage.Weapons[weaponID]:FindFirstChildWhichIsA("Model"):Clone()
	--Check if the item is a tool get the model
	if weaponModel:IsA("Tool") then
		weaponModel = weaponModel:FindFirstChildOfClass("Model"):Clone()
	elseif weaponModel:IsA("Model") then
		weaponModel = weaponModel:Clone()
	end
	self:ApplySkinForPreview(weaponModel, skinData)
	return weaponModel
end

function WeaponCustomizationController:KnitInit() end

return WeaponCustomizationController
