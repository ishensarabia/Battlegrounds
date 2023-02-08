local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets

local LoadoutService = Knit.CreateService({
	Name = "LoadoutService",
	Client = {},
})

function LoadoutService:KnitStart() end

function LoadoutService:GenerateWeaponParts(weaponModel: Model)
	local customParts = {}
	for index, value in weaponModel:GetDescendants() do
		if value:GetAttribute("CustomPart") then
			customParts[value:GetAttribute("CustomPart")] = value
		end
	end
	return customParts
end

function LoadoutService:SpawnLoadout(player)
	local DataService = Knit.GetService("DataService")
	local loadout = DataService:GetLoadout(player)
	if loadout.WeaponEquipped then
		local weaponEquipped: Tool = Assets.Models.Weapons[loadout.WeaponEquipped]:Clone()
        weaponEquipped.Parent = player.Backpack
		--Check for customization
		local weaponCustomization: table = DataService:GetWeaponCustomization(player, loadout.WeaponEquipped)
        warn(weaponCustomization)
		--If there's a customization generate the weapon parts
		if weaponCustomization then
            warn("[LoadoutService] Weapon customization detected ")
			local customParts = self:GenerateWeaponParts(weaponEquipped:FindFirstChildOfClass("Model"))
			for partNumber, customizationValueTable in weaponCustomization do
				if customizationValueTable.Color then
					self:ApplyCustomizationValue(customizationValueTable.Color, partNumber, customParts)
				end
			end
		end
	end
end

function LoadoutService:ApplyCustomizationValue(customizationValue, customNumberPart: number, customParts: table)
	if typeof(customizationValue) == "Color3" then
		local customPart = customParts[customNumberPart]
		customPart.Color = customizationValue
	end
end

function LoadoutService:KnitInit() end

return LoadoutService
