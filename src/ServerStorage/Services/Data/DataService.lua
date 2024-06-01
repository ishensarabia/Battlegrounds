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
		local weaponData = self.Server:GetKeyValue(player, "Weapons")

		if customizationCategory == "Color" then
			--Check if the player removed the color
			if customizationValue == "RemoveColor" then
				weaponData[weaponID].Customization[customPartName].Color = nil
			else
				--Check if the customization has a skin to not overwrite it
				if weaponData[weaponID].Customization[customPartName] then
					if weaponData[weaponID].Customization[customPartName].Skin then
						weaponData[weaponID].Customization[customPartName] = {
							Color = customizationValue,
							Skin = weaponData[weaponID].Customization[customPartName].Skin,
						}
					else
						weaponData[weaponID].Customization[customPartName] = {
							Color = customizationValue,
						}
					end
				else
					weaponData[weaponID].Customization[customPartName] = {
						Color = customizationValue,
					}
				end
			end
		end

		if customizationCategory == "Skins" then
			--Check if the player removed the skin
			if customizationValue == "RemoveSkin" then
				weaponData[weaponID].Customization[customPartName].Skin = nil
			else
				--Check if the customization has a color to not overwrite it
				if weaponData[weaponID].Customization[customPartName] then
					if weaponData[weaponID].Customization[customPartName].Color then
						weaponData[weaponID].Customization[customPartName] = {
							Color = weaponData[weaponID].Customization[customPartName].Color,
							Skin = customizationValue,
						}
					else
						weaponData[weaponID].Customization[customPartName] = {
							Skin = customizationValue,
						}
					end
				else
					weaponData[weaponID].Customization[customPartName] = {
						Skin = customizationValue,
					}
				end
			end
		end

		self.Server:SetKeyValue(player, "Weapons", weaponData)
	end
end

function DataService:GetWeaponCustomization(player, weaponID: string)
	local weaponData = self:GetKeyValue(player, "Weapons")
	local weaponCustomization = {}
	local dictionaryLength = getDictionaryLegnth(weaponData[weaponID].Customization)
	if weaponData[weaponID].Customization and dictionaryLength > 0 then
		for partName, customizationData: table in weaponData[weaponID].Customization do
			if customizationData.Color then
				weaponCustomization[partName] = {
					Color = Color3.new(
						customizationData.Color.Red,
						customizationData.Color.Green,
						customizationData.Color.Blue
					),
				}
			end
			if customizationData.Skin then
				weaponCustomization[partName] = {
					Skin = customizationData.Skin,
				}
			end
		end
	end
	return weaponCustomization
end

function DataService.Client:GetWeaponCustomization(player, weaponID: string)
	local weaponData = self.Server:GetKeyValue(player, "Weapons")
	local weaponCustomization = {}
	local dictionaryLength = getDictionaryLegnth(weaponData[weaponID].Customization)
	if weaponData[weaponID].Customization and dictionaryLength > 0 then
		for partName, customizationData: table in weaponData[weaponID].Customization do
			if customizationData.Color then
				weaponCustomization[partName] = {
					Color = Color3.new(
						customizationData.Color.Red,
						customizationData.Color.Green,
						customizationData.Color.Blue
					),
				}
			end
			if customizationData.Skin then
				weaponCustomization[partName] = {
					Skin = customizationData.Skin,
				}
			end
		end
	end
	return weaponCustomization
end

function DataService:GetLoadout(player)
	local profile = self.profiles[player]
	if profile then
		return profile.Data.Loadout
	end
end

function DataService.Client:GetLoadout(player)
	return self.Server:GetLoadout(player)
end

function DataService:SetWeaponEquipped(player, weapon: string, loadoutSlot: string)
	local profile = self.profiles[player]
	-- warn(profile.Data.Weapons[weapon] )
	if profile and profile.Data.Weapons[weapon] and profile.Data.Weapons[weapon].Owned then
		profile.Data.Loadout.WeaponEquipped = weapon
		profile.Data.Loadout[loadoutSlot] = weapon
	end
end

--Get weapon equipped function
function DataService:GetWeaponEquipped(player)
	local profile = self.profiles[player]
	if profile then
		return profile.Data.Loadout.WeaponEquipped
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
	-- warn(profile.Data)
end


function DataService:GetEmotes(player)
	local profile = self.profiles[player]
	if profile then
		return profile.Data.Emotes
	end
end

function DataService.Client:GetEmotes(player)
	return self.Server:GetEmotes(player)
end

--Has crate function
function DataService:HasCrate(player, crateName: string)
	local profile = self.profiles[player]
	if profile then
		if profile.Data.Crates[crateName] > 0 then
			return true
		else
			return false
		end
	end
end

function DataService:IsWeaponOwned(player, weaponName)
	local profile = self.profiles[player]
    if profile then
        if profile.Data.Weapons[weaponName] then
            return profile.Data.Weapons[weaponName].Owned
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
        if profile.Data.Weapons[weaponName] then
            profile.Data.Weapons[weaponName].Owned = true
        else
            profile.Data.Weapons[weaponName] = {Owned = true, Customization = {}}
        end
    end
end

function DataService:AddCrate(player, crateName: string, needsValue: boolean?)
	local profile = self.profiles[player]
	if profile then
		if profile.Data.Crates[crateName] then
			profile.Data.Crates[crateName] += 1
		else
			profile.Data.Crates[crateName] = 1
		end
	end

	if needsValue then
		return profile.Data.Crates[crateName]
	end
end

function DataService:AddSkin(player, skinName: string)
	local profile = self.profiles[player]
	if profile then
		if profile.Data.Skins[skinName] then
			profile.Data.Skins[skinName] += 1
		else
			profile.Data.Skins[skinName] = 1
		end
	end
end

function DataService:AddEmote(player, emoteName: string, emoteType: string)
	local profile = self.profiles[player]
	-- warn(profile.Data.Emotes)
	if profile then
		if profile.Data.Emotes.EmotesOwned[emoteName] then
			-- profile.Data.Emotes.EmotesOwned[emoteName] += 1
		else
			profile.Data.Emotes.EmotesOwned[emoteName] = {}
			profile.Data.Emotes.EmotesOwned[emoteName].Amount = 1
			profile.Data.Emotes.EmotesOwned[emoteName].Type = emoteType
		end
	end
	-- warn(profile.Data.Emotes.EmotesOwned)
end

function DataService:UnlockWeapon(player, weaponName)
    local profile = self.profiles[player]
    if profile then
        -- Check if the weapon is already unlocked
        if profile.Data.Weapons[weaponName].Owned == true then
            return false, "Weapon is already unlocked"
        end

        -- Unlock the weapon
        profile.Data.Weapons[weaponName].Owned = true

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
		if not playerEmotes.EmotesEquipped[emoteIndex] then		
			playerEmotes.EmotesEquipped[emoteIndex] = {}
		end
		--Identify the emote type
		if emoteType == "Animation" then
			playerEmotes.EmotesEquipped[emoteIndex].animationEmote = emoteName
		end
		if emoteType == "Icon" then
			playerEmotes.EmotesEquipped[emoteIndex].iconEmote = emoteName
		end
	end
	warn(playerEmotes)
end

function DataService:RemoveEmote(player, emoteIndex, emoteType: string)
	local emotes = self:GetEmotes(player)
	if emotes then
		emotes.EmotesEquipped[emoteIndex][emoteType] = nil
	end
end

function DataService:RemoveCrate(player, crateName: string, needsValue: boolean?)
	local profile = self.profiles[player]
	if profile then
		if profile.Data.Crates[crateName] then
			profile.Data.Crates[crateName] -= 1
		else
			profile.Data.Crates[crateName] = 0
		end
	end

	if needsValue then
		return profile.Data.Crates[crateName]
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
	local experience =  dataService:GetKeyValue(player, "Experience")
	local level = dataService:GetKeyValue(player, "Level")
	local experienceToLevelUp = 100 + (level * 50)
	if experience >= experienceToLevelUp then
		dataService:incrementIntValue(player, "Level")
		dataService:incrementIntValue(player, "Experience", -experienceToLevelUp)
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
