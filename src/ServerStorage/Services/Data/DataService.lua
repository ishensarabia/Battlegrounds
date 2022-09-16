local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ProfileService = require(ServerStorage.Source.Services.Data.ProfileService)
local DataConfig = require(ServerStorage.Source.Services.Data.DataConfig)

local DataService = Knit.CreateService {
    Name = "DataService",
    Client = {},
}

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


function DataService:KnitStart()
    self.profiles = {}
	self.profileStore = ProfileService.GetProfileStore("Battlegrounds_Dev1", DataConfig.profileTemplate)
	Players.PlayerRemoving:Connect(function(player)
		self:onPlayerRemoving(player)
	end)
	Players.PlayerAdded:Connect(function(player)
		self:onPlayerAdded(player)
	end)
end

function DataService:GetProfileData(player)
	local profile = self.profiles[player]
	if profile then
		return profile.Data
	end
end

function DataService:GetKeyValue(player, key : string)
	local profile = self.profiles[player]
	if profile and profile.Data[key] then
		return profile.Data[key]
	end
end

function DataService.Client:GetProfileData(player)
	return self.Server:GetProfileData(player)
end

function DataService.Client:GetKeyValue(player, key : string)
	return self.Server:GetKeyValue(player, key)
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


function DataService:setKeyValue(player, key : string, newValue : any)
	local profile = self.profiles[player]
	if profile then
		if profile.Data[key] then			
			profile.Data[key] = newValue
		end
	end
end

function DataService:incrementIntValue(player, key : string, amount : number?)
	assert(type(amount) == "number" or not amount, "Amount is not a number, please verify set parameters")
	local profile = self.profiles[player]
	assert(type(profile.Data[key] == "number"), "Data key is not an int value, please verify parameters values")
	if amount then
		if (profile) then
			profile.Data[key] += amount
		end
	else
		profile.Data[key] += 1
	end
end


function DataService:KnitInit()

end


return DataService
