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

function LoadoutService.Client:GenerateWeaponParts(weaponModel: Model, unknown, uknown2)
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
		local weaponEquipped: Tool = ReplicatedStorage.Weapons[loadout.WeaponEquipped]:Clone()
		weaponEquipped.Parent = player.Backpack
		--Check for customization
		local weaponCustomization: table = DataService:GetWeaponCustomization(player, loadout.WeaponEquipped)
		--If there's a customization generate the weapon parts
		if weaponCustomization then
			warn("[LoadoutService] Weapon customization detected ", weaponCustomization)
			local customParts = self:GenerateWeaponParts(weaponEquipped:FindFirstChildOfClass("Model"))
			for partName, customizationValueTable in weaponCustomization do
				if customizationValueTable.Color then
					self:ApplyCustomizationValue(customizationValueTable.Color, partName, customParts)
				end
				if customizationValueTable.Skin then
					warn("Applying skin", customizationValueTable.Skin)
					self:ApplyCustomizationValue(customizationValueTable.Skin, partName, customParts)
				end
			end
		end
	end
end

function LoadoutService:ApplyCustomizationValue(customizationValue, customPartName: string, customParts: table)
	local customPart = customParts[customPartName]
	if typeof(customizationValue) == "Color3" then
		--Check for light emission and change the color value of it too
		for index, value in customPart:GetChildren() do
			if value:IsA("PointLight") then
				value.Color = customizationValue
			end
		end
		customPart.Color = customizationValue
	end
	if typeof(customizationValue) == "string" then
		local textures = {}
		--It's a texture
		for i = 1, 6, 1 do
			local texture = Instance.new("Texture")
			texture.Name = "Skin"
			texture.Texture = customizationValue
			table.insert(textures, texture)
			texture.Parent = customPart
		end
		textures[1].Face = Enum.NormalId.Back
		textures[2].Face = Enum.NormalId.Bottom
		textures[3].Face = Enum.NormalId.Front
		textures[4].Face = Enum.NormalId.Left
		textures[5].Face = Enum.NormalId.Right
		textures[6].Face = Enum.NormalId.Top
	end
end

function LoadoutService.Client:ApplyCustomization(player, customizationValue, params: table)
	local customPart 
	if params.part then
		customPart = params.part
	end
	if params.customParts then
		customPart = params.customParts[params.partName]
	end
	warn("Applying custom", params.part)
	if typeof(customizationValue) == "Color3" then
		--Check for light emission and change the color value of it too
		for index, value in customPart:GetChildren() do
			if value:IsA("PointLight") then
				value.Color = customizationValue
			end
		end
		customPart.Color = customizationValue
	end
	if typeof(customizationValue) == "string" then
		local textures = {}
		--It's a texture
		for i = 1, 6, 1 do
			local texture = Instance.new("Texture")
			texture.Name = "Skin"
			texture.Texture = customizationValue
			table.insert(textures, texture)
			texture.Parent = customPart
		end
		textures[1].Face = Enum.NormalId.Back
		textures[2].Face = Enum.NormalId.Bottom
		textures[3].Face = Enum.NormalId.Front
		textures[4].Face = Enum.NormalId.Left
		textures[5].Face = Enum.NormalId.Right
		textures[6].Face = Enum.NormalId.Top
	end
end
function LoadoutService:KnitInit() end

return LoadoutService
