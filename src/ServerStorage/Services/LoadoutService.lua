local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Assets = ReplicatedStorage.Assets

local LoadoutService = Knit.CreateService({
	Name = "LoadoutService",
	Client = {
		WeaponBoughtSignal = Knit.CreateSignal(),
	},
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

function LoadoutService:BuyWeapon(player, weaponName)
	warn(player, weaponName)
    local CurrencyService = Knit.GetService("CurrencyService")
    local playerCurrency = CurrencyService:GetCurrencyValue(player, "BattleCoins")
    local playerLevel = player:GetAttribute("Level")

    local weapon = ReplicatedStorage.Weapons[weaponName]
    if not weapon then
        return false, "Weapon does not exist"
    end

    local originalPrice = weapon:GetAttribute("OriginalPrice")
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
        return CurrencyService:BuyWeapon(player, weaponName, isEarlyBuy)
    else
        return false, "Not enough currency to purchase weapon"
    end
end

--Client function
function LoadoutService.Client:BuyWeapon(player, weaponName)
	return self.Server:BuyWeapon(player, weaponName)
end

function LoadoutService:LoadWeaponCustomization(player, weaponName)
	local DataService = Knit.GetService("DataService")
	local weapon = player.Backpack:FindFirstChild(weaponName)

	if weapon then
		local customization = DataService:GetWeaponCustomization(player, weaponName)

		if customization then
			warn("[LoadoutService] Weapon customization detected for " .. weaponName, customization)
			local customParts = self:GenerateWeaponParts(weapon:FindFirstChildOfClass("Model"))

			for partName, customizationValueTable in pairs(customization) do
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
