local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Constants
local SCALING_FACTOR = 1.05
local BASE_LEVEL_UP_XP = 1000
--Config
local BattlepassConfig = require(ServerStorage.Source.Services.Battlepass.BattlepassConfig)

local BattlepassService = Knit.CreateService({
	Name = "BattlepassService",
	Client = {
		LevelUp = Knit.CreateSignal()
	},
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
    battlepassData[battlepassData.currentSeason].Experience = math.clamp(battlepassData[battlepassData.currentSeason].Experience + amount, 0, self:GetExperienceNeededForNextLevel(player))
	self:CheckLevelUp(player)
end

function BattlepassService.Client:AddExperience(player, amount: number)
    return self.Server:AddExperience(player, amount)
end

function BattlepassService:GetExperienceNeededForNextLevel(player)
	local battlepassData = self._dataService:GetKeyValue(player, "Battlepass")
	local xpNeeded = BASE_LEVEL_UP_XP + (BASE_LEVEL_UP_XP * SCALING_FACTOR * (battlepassData[battlepassData.currentSeason].Level - 1))
	return xpNeeded
end

function BattlepassService:CheckLevelUp(player)
	local battlepassData = self._dataService:GetKeyValue(player, "Battlepass")
	local currentSeasonData = battlepassData[battlepassData.currentSeason]
	local xpNeeded = BASE_LEVEL_UP_XP + (BASE_LEVEL_UP_XP * SCALING_FACTOR * (currentSeasonData.Level - 1))
	warn("experience needed", xpNeeded, "current experience", battlepassData.Experience)
	if currentSeasonData.Experience >= xpNeeded then
		currentSeasonData.Level += 1
		currentSeasonData.Experience = 0
		self.Client.LevelUp:Fire(player, currentSeasonData.Level)
	end
end

function BattlepassService.Client:GetExperienceNeededForNextLevel(player : Player)
	return self.Server:GetExperienceNeededForNextLevel(player)
end

return BattlepassService
