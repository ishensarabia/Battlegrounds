local ServerStorage = game:GetService("ServerStorage")
--Services
local ProfileService = require(ServerStorage.Source.Data.ProfileService)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")


local saveStructure = {
	BattleCoins = 0,
	Weapons = {},
	Powers = {},
	Knockouts = 0,
	Defeats = 0,
	LastLogin = os.time(),
	Days = 0,
	Codes = {},
	Settings = {
		["Music"] = true,
	},
	DevProducts = {},
}

--Profile service module to save in the module ProfileService data module about currencies soon
local ProfileStore = ProfileService.GetProfileStore("Development", saveStructure)

local DataHandler = {}

local Profiles = {}

--Functions to get the data structures
function DataHandler:Get(player)
	local profile = Profiles[player]
	if profile then
		return profile.Data
	end
end

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
	for k, v in (template) do
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

local function onPlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId, "ForceLoad")

	if profile then
		profile:ListenToRelease(function()
			Profiles[player] = nil
			player:Kick()
		end)

		if player:IsDescendantOf(Players) then
			Profiles[player] = profile
			MergeDataWithTemplate(profile.Data, saveStructure)
			game.ReplicatedStorage.Data.LoadData:Fire(player)
		else
			profile:Release()
		end
	else
		player:Kick()
	end
end

function onPlayerRemoving(player)
	local profile = Profiles[player]
	if profile then
		profile:Release()
	end
end

local function LengthOfDictionary(Table)
	local counter = 0
	for _, v in pairs(Table) do
		counter = counter + 1
	end
	return counter
end

function DataHandler.AddContainers(player, amount)
	local data = DataHandler:Get(player)

	while LengthOfDictionary(data.CompanionsData.Containers) < amount do
		data.CompanionsData.Containers[LengthOfDictionary(data.CompanionsData.Containers) + 1] = {
			["Id"] = HttpService:GenerateGUID(false),
			["Name"] = LengthOfDictionary(data.CompanionsData.Containers) + 1,
			["Companions"] = {},
		}
	end
	DataHandler.CompanionsContainersDataToInstances(data.CompanionsData.Containers, player.CompanionsContainers)
end

function DataHandler.WipeData(player)
	local data = DataHandler:Get(player)
	data = {}
	player:Kick("Your data has been wiped")
end

--Connecting events
Players.PlayerRemoving:Connect(onPlayerRemoving)

Players.PlayerAdded:Connect(onPlayerAdded)

return DataHandler
