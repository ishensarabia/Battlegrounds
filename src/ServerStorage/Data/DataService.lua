local ServerStorage = game:GetService("ServerStorage")
--Services
local ProfileService = require(ServerStorage.Source.Data.ProfileService)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
--Config
local DataConfig = require(ServerStorage.Source.Services.Data.DataConfig)


-- local saveStructure = {
-- 	BattleCoins = 0,
-- 	Weapons = {},
-- 	Powers = {},
-- 	Knockouts = 0,
-- 	Defeats = 0,
-- 	LastLogin = os.time(),
-- 	ObjectsDestroyed = 0,
-- 	Days = 0,
-- 	Codes = {},
-- 	Settings = {
-- 		["Music"] = true,
-- 	},
-- 	DevProducts = {},
-- }

-- --Profile service module to save in the module ProfileService data module about currencies soon
-- local ProfileStore = ProfileService.GetProfileStore("Battlegrounds_Dev", saveStructure)

local DataService = {}

-- local Profiles = {}      

-- --Functions to get the data structures
-- function DataService:GetProfileData(player)
-- 	local profile = Profiles[player]
-- 	if profile then
-- 		return profile.Data
-- 	end
-- end


-- local function DeepCopy(original)
-- 	local copy = {}
-- 	for k, v in pairs(original) do
-- 		if type(v) == "table" then
-- 			v = DeepCopy(v)
-- 		end
-- 		copy[k] = v --deep copy
-- 	end
-- 	return copy
-- end

-- local function MergeDataWithTemplate(data, template)
-- 	for k, v in (template) do
-- 		if type(k) == "string" then -- Only string keys will be merged
-- 			if data[k] == nil then
-- 				if type(v) == "table" then
-- 					data[k] = DeepCopy(v)
-- 				else
-- 					data[k] = v
-- 				end
-- 			elseif type(data[k]) == "table" and type(v) == "table" then
-- 				MergeDataWithTemplate(data[k], v)
-- 			end
-- 		end
-- 	end
-- end



-- function DataService.WipeData(player)
-- 	local data = DataService:GetProfileData(player)
-- 	data = {}
-- 	player:Kick("Your data has been wiped")
-- end

-- function DataService.setKeyValue(player, key : string, newValue : any)
-- 	local profile = Profiles[player]
-- 	if profile then
-- 		if profile.Data[key] then			
-- 			profile.Data[key] = newValue
-- 		end
-- 	end
-- end

-- function DataService.incrementIntValue(player, key : string, amount : number?)
-- 	assert(type(amount) == "number" or not amount, "Amount is not a number, please verify set parameters")
-- 	local profile = Profiles[player]
-- 	assert(type(profile.Data[key] == "number"), "Data key is not an int value, please verify parameters values")
-- 	if amount then
-- 		if (profile) then
-- 			profile.Data[key] += amount
-- 		end
-- 	else
-- 		profile.Data[key] += 1
-- 	end
-- end
--Connecting events
-- Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Players.PlayerAdded:Connect(onPlayerAdded)

return DataService
