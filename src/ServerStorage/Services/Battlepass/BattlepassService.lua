local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Constants
local SCALING_FACTOR = 0.05
local BASE_LEVEL_UP_XP = 1000
--Config
local BattlepassConfig = require(ServerStorage.Source.Services.Battlepass.BattlepassConfig)

local BattlepassService = Knit.CreateService({
	Name = "BattlepassService",
	Client = {},
})

function BattlepassService:KnitStart()
	self._dataService = Knit.GetService("DataService")
end

function BattlepassService:KnitInit() end

function BattlepassService:GetBattlepassData(player: Player)
	local battlepassData = self._dataService:GetKeyValue(player, "Battlepass")
	return battlepassData
end

--Client get battlepass data
function BattlepassService.Client:GetBattlepassData(player: Player)
	return self.Server:GetBattlepassData(player)
end

function BattlepassService.Client:GetSeasonRewards(player: Player)
	local battlepassData = self.Server:GetBattlepassData(player)
	local seasonRewards = BattlepassConfig.rewards[battlepassData.currentSeason]
	return seasonRewards
end

function BattlepassService:GetSeasonExperience(player: Player)
	local battlepassData = self:GetBattlepassData(player)
	local seasonExperience = battlepassData.Experience
	return seasonExperience
end

function BattlepassService.Client:GetSeasonExperince(player)
	return self.Server:GetSeasonExperience(player)
end

function BattlepassService:AddExperience(player, amount: number)
	local battlepassData = self._dataService:GetKeyValue(player, "Battlepass")
    warn(battlepassData[battlepassData.currentSeason])
    battlepassData[battlepassData.currentSeason].Experience += amount
end

function BattlepassService.Client:AddExperience(player, amount: number)
    return self.Server:AddExperience(player, amount)
end

return BattlepassService
