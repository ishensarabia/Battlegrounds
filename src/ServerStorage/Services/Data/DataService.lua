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

local function getDictionaryLegnth(t)
	local n = 0
	for _ in pairs(t) do
		n = n + 1
	end
	return n
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
	-- Initialize profiles table0 to store
	self.profiles = {}
	self.profileStore = ProfileService.GetProfileStore("Development_Alpha_11", DataConfig.profileTemplate)
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

function DataService.Client:SaveWeaponCustomization(
	player,
	weaponID: string,
	customPartName: string,
	customizationValue,
	customizationCategory: string
)
	if customizationValue then
		local weaponData = self.Server:GetKeyValue(player, "weapons")

		if customizationCategory == "Color" then
			--Check if the player removed the color
			if customizationValue == "RemoveColor" then
				weaponData[weaponID].customization[customPartName].Color = nil
			else
				--Check if the customization has a skin to not overwrite it
				if weaponData[weaponID].customization[customPartName] then
					if weaponData[weaponID].customization[customPartName].skin then
						weaponData[weaponID].customization[customPartName] = {
							Color = customizationValue,
							skin = weaponData[weaponID].customization[customPartName].skin,
						}
					else
						weaponData[weaponID].customization[customPartName] = {
							Color = customizationValue,
						}
					end
				else
					weaponData[weaponID].customization[customPartName] = {
						Color = customizationValue,
					}
				end
			end
		end

		if customizationCategory == "skins" then
			--Check if the player removed the skin
			if customizationValue == "RemoveSkin" then
				weaponData[weaponID].customization[customPartName].skin = nil
			else
				--Check if the customization has a color to not overwrite it
				if weaponData[weaponID].customization[customPartName] then
					if weaponData[weaponID].customization[customPartName].Color then
						weaponData[weaponID].customization[customPartName] = {
							Color = weaponData[weaponID].customization[customPartName].Color,
							skin = customizationValue,
						}
					else
						weaponData[weaponID].customization[customPartName] = {
							skin = customizationValue,
						}
					end
				else
					weaponData[weaponID].customization[customPartName] = {}
					weaponData[weaponID].customization[customPartName] = {
						skin = customizationValue,
					}
				end
			end
		end
		self.Server:SetKeyValue(player, "weapons", weaponData)
	end
end

function DataService:GetWeaponCustomization(player, weaponID: string)
	local weaponData = self:GetKeyValue(player, "weapons")
	local weaponCustomization = {}
	local dictionaryLength = getDictionaryLegnth(weaponData[weaponID].customization)
	if weaponData[weaponID].customization and dictionaryLength > 0 then
		for partName, customizationData: table in weaponData[weaponID].customization do
			if customizationData.Color then
				weaponCustomization[partName] = {
					color = Color3.new(
						customizationData.Color.Red,
						customizationData.Color.Green,
						customizationData.Color.Blue
					),
				}
			end
			if customizationData.skin then
				weaponCustomization[partName] = {
					skin = customizationData.skin,
				}
			end
		end
	end
	return weaponCustomization
end

function DataService.Client:GetWeaponCustomization(player, weaponID: string)
	local weaponData = self.Server:GetKeyValue(player, "weapons")
	local weaponCustomization = {}
	local dictionaryLength = getDictionaryLegnth(weaponData[weaponID].customization)
	if weaponData[weaponID].customization and dictionaryLength > 0 then
		for partName, customizationData: table in weaponData[weaponID].customization do
			if customizationData.color then
				weaponCustomization[partName] = {
					color = Color3.new(
						customizationData.Color.Red,
						customizationData.Color.Green,
						customizationData.Color.Blue
					),
				}
			end
			if customizationData.skin then
				weaponCustomization[partName] = {
					skin = customizationData.skin,
				}
			end
		end
	end
	return weaponCustomization
end

function DataService:GetLoadout(player)
	local profile = self.profiles[player]
	if profile then
		return profile.Data.loadout
	end
end

function DataService.Client:GetLoadout(player)
	return self.Server:GetLoadout(player)
end

function DataService:SetWeaponEquipped(player, weapon: string, loadoutSlot: string)
	local profile = self.profiles[player]
	-- warn(profile.Data.weapons[weapon] )
	if profile and profile.Data.weapons[weapon] and profile.Data.weapons[weapon].owned then
		profile.Data.loadout.weaponEquipped = weapon
		profile.Data.loadout[loadoutSlot] = weapon
	end
end

--Get weapon equipped function
function DataService:GetWeaponEquipped(player)
	local profile = self.profiles[player]
	if profile then
		return profile.Data.Loadout.weaponEquipped
	end
end
--Get weapon equipped function
function DataService.Client:GetWeaponEquipped(player)
	return self.Server:GetWeaponEquipped(player)
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

function DataService:WipeData(player)
	local profile = self.profiles[player]
	if profile then
		profile.Data = DataConfig.profileTemplate
		player:Kick("Your data has been wiped")
	end
end

function DataService:SetKeyValue(player, key: string, newValue: any)
	local profile = self.profiles[player]
	if profile then
		if profile.Data[key] then
			profile.Data[key] = newValue
		end
	end
	-- warn(profile.Data)
end

function DataService:GetEmotes(player)
	local profile = self.profiles[player]
	if profile then
		return profile.Data.emotes
	end
end

function DataService.Client:GetEmotes(player)
	return self.Server:GetEmotes(player)
end

--Has crate function
function DataService:HasCrate(player, crateName: string)
	local profile = self.profiles[player]
	if profile then
		if profile.Data.crates[crateName] > 0 then
			return true
		else
			return false
		end
	end
end

function DataService:IsWeaponOwned(player, weaponName)
	local profile = self.profiles[player]
	if profile then
		if profile.Data.weapons[weaponName] then
			return profile.Data.weapons[weaponName].owned
		end
	end
end

--Client
function DataService.Client:IsWeaponOwned(player, weaponName)
	return self.Server:IsWeaponOwned(player, weaponName)
end

function DataService:AddWeapon(player, weaponName: string)
	local profile = self.profiles[player]
	if profile then
		if profile.Data.weapons[weaponName] then
			profile.Data.weapons[weaponName].owned = true
		else
			profile.Data.weapons[weaponName] = table.clone(DataConfig.weaponTemplate)
		end
	end
end

function DataService:AddCrate(player, crateName: string, needsValue: boolean?)
	local profile = self.profiles[player]
	if profile then
		if profile.Data.crates[crateName] then
			profile.Data.crates[crateName] += 1
		else
			profile.Data.crates[crateName] = 1
		end
	end

	if needsValue then
		return profile.Data.crates[crateName]
	end
end

function DataService:AddSkin(player, skinName: string)
	local profile = self.profiles[player]
	if profile then
		if profile.Data.skins[skinName] then
			profile.Data.skins[skinName] += 1
		else
			profile.Data.skins[skinName] = 1
		end
	end
end

function DataService:AddEmote(player, emoteName: string, emoteType: string)
	local profile = self.profiles[player]
if profile then
		if profile.Data.emotes.emotesOwned[emoteName] then
			-- profile.Data.emotes.emotesOwned[emoteName] += 1
		else
			profile.Data.emotes.emotesOwned[emoteName] = {}
			profile.Data.emotes.emotesOwned[emoteName].Amount = 1
			profile.Data.emotes.emotesOwned[emoteName].Type = emoteType
		end
	end
	warn(profile.Data.emotes)
	-- warn(profile.Data.emotes.emotesOwned)
end

function DataService:UnlockWeapon(player, weaponName)
	local profile = self.profiles[player]
	if profile then
		-- Check if the weapon is already unlocked
		if profile.Data.weapons[weaponName].owned == true then
			return false, "Weapon is already unlocked"
		end

		-- Unlock the weapon
		profile.Data.weapons[weaponName].owned = true

		return true, "Weapon unlocked successfully"
	else
		return false, "Player profile does not exist"
	end
end

--Function to save emotes (animation and icon) and other emote data and so
function DataService:SaveEmote(player, emoteIndex, emoteName, emoteType: string)
	warn(player, emoteIndex, emoteName, emoteType)
	local playerEmotes = self:GetEmotes(player)
	if playerEmotes then
		--format the emote name to be the same as the emote name in the emotes table
		emoteName = emoteName:gsub(" ", "_")
		emoteName = emoteName:gsub("'", "")
		--Check if there's any emote equipped in the emote index
		if not playerEmotes.emotesEquipped[emoteIndex] then
			playerEmotes.emotesEquipped[emoteIndex] = {}
		end
		--Identify the emote type
		if emoteType == "Animation" then
			playerEmotes.emotesEquipped[emoteIndex].animationEmote = emoteName
		end
		if emoteType == "Icon" then
			playerEmotes.emotesEquipped[emoteIndex].iconEmote = emoteName
		end
	end
	warn(playerEmotes)
end

function DataService:RemoveEmote(player, emoteIndex, emoteType: string)
	local emotes = self:GetEmotes(player)
	if emotes then
		emotes.emotesEquipped[emoteIndex][emoteType] = nil
	end
end

function DataService:RemoveCrate(player, crateName: string, needsValue: boolean?)
	local profile = self.profiles[player]
	if profile then
		if profile.Data.crates[crateName] then
			profile.Data.crates[crateName] -= 1
		else
			profile.Data.crates[crateName] = 0
		end
	end

	if needsValue then
		return profile.Data.crates[crateName]
	end
end

--Add experience to the player
function DataService:AddExperience(player: Player, amount: number)
	local dataService = Knit.GetService("DataService")
	dataService:incrementIntValue(player, "Experience", amount)
	self:CheckLevelUp(player)
end

--Check if the player has enough experience to level up
function DataService:CheckLevelUp(player: Player)
	local dataService = Knit.GetService("DataService")
	local experience = dataService:GetKeyValue(player, "experience")
	local level = dataService:GetKeyValue(player, "level")
	local experienceToLevelUp = 100 + (level * 50)
	if experience >= experienceToLevelUp then
		dataService:incrementIntValue(player, "level")
		dataService:incrementIntValue(player, "experience", -experienceToLevelUp)
		self:CheckLevelUp(player)
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
