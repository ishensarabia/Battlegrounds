local MarketplaceService = game:GetService("MarketplaceService")
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
		LevelUp = Knit.CreateSignal(),
		BattlepassExperienceAdded = Knit.CreateSignal(),
	},
})

function BattlepassService:KnitStart()
	self._dataService = Knit.GetService("DataService")
	self._storeService = Knit.GetService("StoreService")
	self._currencyService = Knit.GetService("CurrencyService")
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

function BattlepassService.Client:GetBattlepassConfig()
	return BattlepassConfig
end

function BattlepassService:GetSeasonExperience(player: Player)
	local battlepassData = self:GetBattlepassData(player)
	local seasonExperience = battlepassData.Experience
	return seasonExperience
end

function BattlepassService.Client:GetSeasonExperince(player)
	return self.Server:GetSeasonExperience(player)
end

function BattlepassService:ClaimBattlepassReward(player, rewardLevel: number)
	local battlepassData = self:GetBattlepassData(player)
	local seasonData = battlepassData[battlepassData.currentSeason]
	local seasonRewards = BattlepassConfig.rewards[battlepassData.currentSeason]
	local levelRewards: table = seasonRewards[rewardLevel]
	--Check if the player owns the battlepass season
	--Check if the player hasn't already claimed the reward
	warn(
		seasonData.ClaimedLevels,
		rewardLevel,
		table.find(seasonData.ClaimedLevels, rewardLevel),
		seasonData.ClaimedLevels[rewardLevel]
	)
	if not seasonData.ClaimedLevels[rewardLevel] then
		--Check if the player has reached the required level
		if seasonData.Level >= rewardLevel then
			--Check if the player owns the battlepass
			if battlepassData.OwnsBattlepass then
				--Give the player the rewards
				for rewardCategory, levelItemRewards in levelRewards do
					for index, rewardData: table in levelItemRewards do
						if
							rewardData.rewardType == BattlepassConfig.RewardTypes.BattleCoins
							or rewardData.rewardType == BattlepassConfig.RewardTypes.BattleGems
						then
							--Add currency
							self._currencyService:AddCurrency(player, rewardData.rewardType, rewardData.amount)
						end
						if rewardData.rewardType == BattlepassConfig.RewardTypes.Skin then
							--Add skin
							self._dataService:AddSkin(player, rewardData.rewardSkin.name)
						end
						if rewardData.rewardType == BattlepassConfig.RewardTypes.Crate then
							--Add crate
							local totalAmountOfCrates = self._dataService:AddCrate(player, rewardData.crateName)
							--Fire the signal
							self._storeService.Client.CrateAddedSignal:Fire(player, rewardData.crateName, totalAmountOfCrates)
						end
					end
				end
			else
				--Give the player the rewards
				for rewardCategory, levelItemRewards in levelRewards do
					for index, rewardData: table in levelItemRewards do
						if
							rewardData.rewardType == BattlepassConfig.RewardTypes.BattleCoins
							or rewardData.rewardType == BattlepassConfig.RewardTypes.BattleGems
						then
							--Add currency
							self._currencyService:AddCurrency(player, rewardData.rewardType, rewardData.rewardAmount)
						end
						if rewardData.rewardType == BattlepassConfig.RewardTypes.Skin then
							--Add skin
							self._dataService:AddSkin(player, rewardData.rewardSkin.name)
						end

						if rewardData.rewardType == BattlepassConfig.RewardTypes.Crate then
							--Add crate
							local totalAmountOfCrates = self._dataService:AddCrate(player, rewardData.crateName)
							--Fire the signal
							self._storeService.Client.CrateAddedSignal:Fire(player, rewardData.crateName, totalAmountOfCrates)
						end
					end
				end
			end
			--Mark the reward as claimed
			table.insert(seasonData.ClaimedLevels, rewardLevel)
			--Save the data
			self._dataService:SetKeyValue(player, "Battlepass", battlepassData)
		end
	end
end

--client claim reward function
function BattlepassService.Client:ClaimBattlepassReward(player: Player, rewardLevel: number)
	self.Server:ClaimBattlepassReward(player, rewardLevel)
end

function BattlepassService:AddBattlepassExperience(player, amount: number)
	local battlepassData = self._dataService:GetKeyValue(player, "Battlepass")
	local currentSeasonData = battlepassData[battlepassData.currentSeason]
	local experienceToAdd = amount
	while experienceToAdd > 0 do
		local xpNeeded = self:GetExperienceNeededForNextLevel(player)
		local experienceGap = xpNeeded - currentSeasonData.Experience
		if experienceToAdd >= experienceGap then
			currentSeasonData.Level += 1
			experienceToAdd -= experienceGap
			currentSeasonData.Experience = 0
			self.Client.LevelUp:Fire(player, currentSeasonData.Level)
		else
			currentSeasonData.Experience += experienceToAdd
			experienceToAdd = 0
		end
		self.Client.BattlepassExperienceAdded:Fire(player, currentSeasonData)
	end
end

function BattlepassService:GetExperienceNeededForNextLevel(player)
	local battlepassData = self._dataService:GetKeyValue(player, "Battlepass")
	local currentSeasonData = battlepassData[battlepassData.currentSeason]
	local xpNeeded = BASE_LEVEL_UP_XP + (BASE_LEVEL_UP_XP * SCALING_FACTOR * (currentSeasonData.Level - 1))
	return xpNeeded
end

function BattlepassService:CheckLevelUp(player)
	local battlepassData = self._dataService:GetKeyValue(player, "Battlepass")
	local currentSeasonData = battlepassData[battlepassData.currentSeason]
	local xpNeeded = self:GetExperienceNeededForNextLevel(player)
	warn("experience needed", xpNeeded, "current experience", battlepassData.Experience)
	if currentSeasonData.Experience >= xpNeeded then
		currentSeasonData.Level += 1
		currentSeasonData.Experience = 0
		self.Client.LevelUp:Fire(player, currentSeasonData.Level)
	end
end

function BattlepassService.Client:GetExperienceNeededForNextLevel(player: Player)
	return self.Server:GetExperienceNeededForNextLevel(player)
end

function BattlepassService:BuyBattlepass() end

function BattlepassService.Client:BuyBattlepass(player: Player)
	local battlepassData = self.Server:GetBattlepassData(player)
	MarketplaceService:PromptProductPurchase(
		player,
		BattlepassConfig.seasonDevProdctsDictionary[battlepassData.currentSeason]
	)
end

return BattlepassService
