local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ProfileService = require(ServerStorage.Source.Services.Data.ProfileService)
local DataConfig = require(ServerStorage.Source.Services.Data.DataConfig)

local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {
		BattleCoinsChanged = Knit.CreateSignal(),
		BattleGemsChanged = Knit.CreateSignal(),
	},
	Initialized = false,
})

local function DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = DeepCopy(v)
		end
		copy[k] = v --deep copy
	end
	return copy
end

local function MergeDataWithTemplate(data, template)
	for k, v in template do
		if type(k) == "string" then -- Only string keys will be merged
			if data[k] == nil then
				if type(v) == "table" then
					data[k] = DeepCopy(v)
				else
					data[k] = v
				end
			elseif type(data[k]) == "table" and type(v) == "table" then
				MergeDataWithTemplate(data[k], v)
			end
		end
	end
end

function DataService:KnitStart()
	-- Initialize profiles table to store
	self.profiles = {}
	self.profileStore = ProfileService.GetProfileStore("TestingAlpha?9", DataConfig.profileTemplate)
	Players.PlayerRemoving:Connect(function(player)
		self:onPlayerRemoving(player)
	end)
	Players.PlayerAdded:Connect(function(player)
		self:onPlayerAdded(player)
	end)
	self.Initialized = true
end

function DataService:GetProfileData(player)
	local profile = self.profiles[player]
	if profile then
		return profile.Data
	end
end

function DataService:GetKeyValue(player, key: string)
	repeat
		task.wait() --make sure the porfile is there
	until self.profiles[player]
	-- warn(self.profiles[player].Data[key]) -- set usage for the player profile
	local profile = self.profiles[player]
	if profile and profile.Data[key] then
		return profile.Data[key]
	end
end

function DataService.Client:GetProfileData(player)
	return self.Server:GetProfileData(player)
end

function DataService.Client:GetKeyValue(player, key: string)
	return self.Server:GetKeyValue(player, key)
end

function DataService.Client:ApplyWeaponCustomization(
	player,
	weaponID: string,
	customPartNumber: number,
	customizationValue,
	customizationCategory: string
)
	if customizationValue then
		local weaponData = self.Server:GetKeyValue(player, "Weapons")
		if customizationCategory == "Color" then
			weaponData[weaponID].Customization[customPartNumber] = {
				Color = { Red = customizationValue.R, Green = customizationValue.G, Blue = customizationValue.B },
			}
		end
		warn(weaponData)
	end
end

function DataService:GetWeaponCustomization(player, weaponID: string)
	local profile = self.profiles[player]
	local weaponData = profile.Data.Weapons
	local weaponCustomization = {}
	if weaponData[weaponID].Customization and #weaponData[weaponID].Customization > 0 then
		for partNumber, customizationValue in weaponData[weaponID].Customization do
			if customizationValue.Color then
				weaponCustomization[partNumber] = {
					Color = Color3.new(
						customizationValue.Color.Red,
						customizationValue.Color.Green,
						customizationValue.Color.Blue
					),
				}
			end
		end
	end
	return weaponCustomization
end

function DataService.Client:GetWeaponCustomization(player, weaponID: string)
	local weaponData = self.Server:GetKeyValue(player, "Weapons")
	local weaponCustomization = {}
	if weaponData[weaponID].Customization and #weaponData[weaponID].Customization > 0 then
		for partNumber, customizationValue in weaponData[weaponID].Customization do
			if customizationValue.Color then
				weaponCustomization[partNumber] = {
					Color = Color3.new(
						customizationValue.Color.Red,
						customizationValue.Color.Green,
						customizationValue.Color.Blue
					),
				}
			end
		end
	end
	return weaponCustomization
end

function DataService:GetWeaponEquipped(player, weapon: string)
	local profile = self.profiles[player]
	if profile then
		return profile.Data.WeaponEquipped
	end
end

function DataService:GetLoadout(player)
	local profile = self.profiles[player]
	if profile then
		return profile.Data.Loadout
	end
end

function DataService:SetWeaponEquipped(player, weapon: string)
	local profile = self.profiles[player]
	if profile and profile.Data.Weapons[weapon] then
		profile.Data.Loadout.WeaponEquipped = weapon
	end
end

function DataService.Client:SetWeaponEquipped(player, weapon: string)
	return self.Server:SetWeaponEquipped(player, weapon)
end

function DataService:onPlayerAdded(player)
	local profile = self.profileStore:LoadProfileAsync("Player_" .. player.UserId, "ForceLoad")
	if profile then
		profile:ListenToRelease(function()
			self.profiles[player] = nil
			player:Kick()
		end)

		if player:IsDescendantOf(Players) then
			self.profiles[player] = profile
			MergeDataWithTemplate(profile.Data, DataConfig.profileTemplate)
		else
			profile:Release()
		end
	else
		player:Kick()
	end
end

function DataService:onPlayerRemoving(player)
	local profile = self.profiles[player]
	if profile then
		profile:Release()
	end
end

function DataService.WipeData(player)
	local data = DataService:GetProfileData(player)
	data = {}
	player:Kick("Your data has been wiped")
end

function DataService:SetKeyValue(player, key: string, newValue: any)
	local profile = self.profiles[player]
	if profile then
		if profile.Data[key] then
			profile.Data[key] = newValue
		end
	end
end

function DataService:incrementIntValue(player, key: string, amount: number?)
	assert(type(amount) == "number" or not amount, "Amount is not a number, please verify set parameters")
	local profile = self.profiles[player]
	assert(profile, "Profile not found, please verify player is in game")
	assert(type(profile.Data[key] == "number"), "Data key is not an int value, please verify parameters values")
	if amount then
		if profile then
			profile.Data[key] += amount or 1
		end
	else
		profile.Data[key] += 1
	end
end

function DataService:KnitInit() end

return DataService