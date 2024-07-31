local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Skins = require(ReplicatedStorage.Source.Assets.Skins)
--Enums
local CurrenciesEnum = require(ReplicatedStorage.Source.Enums.CurrenciesEnum)

local LoadoutService = Knit.CreateService({
	Name = "LoadoutService",
	Client = {
		WeaponBoughtSignal = Knit.CreateSignal(),
	},
})

function LoadoutService:KnitStart()
	self._dataService = Knit.GetService("DataService")
end

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

	if loadout.Primary then
		local primaryWeapon = ReplicatedStorage.Weapons[loadout.Primary]:Clone()
		primaryWeapon.Parent = player.Backpack

		-- Load customization for primary and secondary weapons
		self:LoadWeaponCustomization(player, loadout.Primary)
	end

	if loadout.Secondary then
		local secondaryWeapon = ReplicatedStorage.Weapons[loadout.Secondary]:Clone()
		secondaryWeapon.Parent = player.Backpack
		self:LoadWeaponCustomization(player, loadout.Secondary)
	end
end

function LoadoutService:SetWeaponEquipped(player, weaponName, loadoutSlot)
	self._dataService:SetWeaponEquipped(player, weaponName, loadoutSlot)
end

function LoadoutService.Client:SetWeaponEquipped(player, weaponName, loadoutSlot)
	return self.Server:SetWeaponEquipped(player, weaponName, loadoutSlot)
end

function LoadoutService:PurchasePrestigeWeapon(player, weaponName)
	local CurrencyService = Knit.GetService("CurrencyService")
	local playerCurrency = CurrencyService:GetCurrencyValue(player, CurrenciesEnum.BattleGems)
	local weapon = ReplicatedStorage.Weapons[weaponName]
	if not weapon then
		error("Weapon does not exist")
	end

	assert(weapon:GetAttribute("RequiredPrestige"), "Weapon does not require prestige")
	assert(player:GetAttribute("Prestige"), "Player does not have prestige")

	if player:GetAttribute("Prestige") >= weapon:GetAttribute("RequiredPrestige") then
		return CurrencyService:PurchasePrestigeWeapon(player, weaponName)
	else
		return false, "Not enough currency to purchase weapon"
	end
end

function LoadoutService.Client:PurchasePrestigeWeapon(player, weaponName)
	return self.Server:PurchasePrestigeWeapon(player, weaponName)
end

function LoadoutService:PurchaseWeapon(player, weaponName)
	local CurrencyService = Knit.GetService("CurrencyService")
	local playerCurrency = CurrencyService:GetCurrencyValue(player, CurrenciesEnum.BattleGems)
	local playerLevel = player:GetAttribute("Level")

	local weapon = ReplicatedStorage.Weapons[weaponName]
	if not weapon then
		error("Weapon does not exist")
	end

	local originalPrice = weapon:GetAttribute("Price")
	local earlyPrice = weapon:GetAttribute("EarlyPrice")
	local requiredLevel = weapon:GetAttribute("RequiredLevel")
	local isEarlyBuy

	local weaponPrice
	if playerLevel >= requiredLevel then
		weaponPrice = originalPrice
		isEarlyBuy = false
	else
		weaponPrice = earlyPrice
		isEarlyBuy = true
	end

	if playerCurrency >= weaponPrice then
		self.Client.WeaponBoughtSignal:Fire(player, weaponName)
		return CurrencyService:PurchaseWeapon(player, weaponName, isEarlyBuy)
	else
		return false, "Not enough currency to purchase weapon"
	end
end

--Client function
function LoadoutService.Client:PurchaseWeapon(player, weaponName)
	return self.Server:PurchaseWeapon(player, weaponName)
end

function LoadoutService:LoadWeaponCustomization(player, weaponName)
	local DataService = Knit.GetService("DataService")
	local weapon = player.Backpack:FindFirstChild(weaponName)

	if weapon then
		local customization = DataService:GetWeaponCustomization(player, weaponName)

		if customization then
			local customParts = self:GenerateWeaponParts(weapon:FindFirstChildOfClass("Model"))

			for partName, customizationValueTable in (customization) do
				if customizationValueTable.color then
					self:ApplyCustomizationValue(customizationValueTable.color, partName, customParts)
				end

				if customizationValueTable.skin then
					self:ApplyCustomizationValue(customizationValueTable.skin, partName, customParts)
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
			texture.StudsPerTileU = 0.2
			texture.StudsPerTileV = 0.3
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
		--Get skin data from the customization value to check if it should animate
		for skinID, skinData in (Skins) do
			if skinData.skinID == customizationValue then
				if skinData.shouldAnimate then
					CollectionService:AddTag(customPart.Parent.Parent, "AnimatedWeaponSkin")
					break
				end
			end
		end
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
