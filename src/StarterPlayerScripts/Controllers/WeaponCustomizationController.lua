local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Modules
local DragToRotateViewportFrame = require(ReplicatedStorage.Source.Modules.Util.DragToRotateViewportFrame)
--Main controller
local WeaponCustomizationController = Knit.CreateController({ Name = "WeaponCustomizationController" })

--Widgets
local WeaponCustomWidget = require(game.StarterPlayer.StarterPlayerScripts.Source.UI_Widgets.WeaponCustomWidget)

function WeaponCustomizationController:KnitStart()
	--services
	self._dataService = Knit.GetService("DataService")
end

function WeaponCustomizationController:ApplySkinForPreview(weaponModel, skinID: string)
	--Get weapon parts to apply the skin
	for index, value in weaponModel:GetDescendants() do
		if value:GetAttribute("CustomPart") then
			local textures = {}
			--It's a texture
			for i = 1, 6, 1 do
				local texture = Instance.new("Texture")
				texture.Name = "Skin"
				texture.Texture = skinID
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
end

function WeaponCustomizationController:CreateWeaponPreviewWithSkin(weaponID : string, skinID : string)
    warn(weaponID, skinID)
	local weaponModel = ReplicatedStorage.Weapons.Preview[weaponID]:Clone()
	--Check if the item is a tool get the model
	if weaponModel:IsA("Tool") then
		weaponModel = weaponModel:FindFirstChildOfClass("Model"):Clone()
	elseif weaponModel:IsA("Model") then
		weaponModel = weaponModel:Clone()
	end
    self:ApplySkinForPreview(weaponModel, skinID)
    return weaponModel
end

function WeaponCustomizationController:KnitInit() end

return WeaponCustomizationController
