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

function BattlepassService:ClaimBattlepassReward(player, rewardLevel: number, rewardType: string)
	local battlepassData = self:GetBattlepassData(player)
	local seasonData = battlepassData[battlepassData.currentSeason]
	local seasonRewards = BattlepassConfig.rewards[battlepassData.currentSeason]
	local levelRewards: table = seasonRewards[rewardLevel]
	--Check if the player owns the battlepass season
	--Check if the player hasn't already claimed the reward
	warn(
		seasonData.ClaimedLevels,
		rewardLevel,
		rewardType
	)
	--if it's premium reward check if the player has the battlepass
	if rewardType == "Battlepass" then
		if not seasonData.ClaimedLevels.Battlepass[rewardLevel] then
			--Check if the player owns the battlepass
			if seasonData.Owned then
				warn("Owns the battlepass")
				--Give the player the rewards
				for index, rewardData: table in levelRewards.battlepass do
					warn(rewardData)
					if
						rewardData.rewardType == BattlepassConfig.RewardTypes.BattleCoins
						or rewardData.rewardType == BattlepassConfig.RewardTypes.BattleGems
					then
						--Add currency
						warn("Adding currency")
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
						self._storeService.Client.CrateAddedSignal:Fire(
							player,
							rewardData.crateName,
							totalAmountOfCrates
						)
					end
					if rewardData.rewardType == BattlepassConfig.RewardTypes.Emote then
						self._dataService:AddEmote(player, rewardData.rewardEmote.name)
					end
				end
				--If it hasn't been claimed the free reward claim it as well
				if not seasonData.ClaimedLevels.Freepass[rewardLevel] then
					for index, rewardData in levelRewards.freepass do
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
							self._storeService.Client.CrateAddedSignal:Fire(
								player,
								rewardData.crateName,
								totalAmountOfCrates
							)
						end
						if rewardData.rewardType == BattlepassConfig.RewardTypes.Emote then
							self._dataService:AddEmote(player, rewardData.rewardEmote.name)
						end
					end
				end
				table.insert(seasonData.ClaimedLevels.Battlepass, rewardLevel)
				table.insert(seasonData.ClaimedLevels.Freepass, rewardLevel)
			else
				warn("Doesn't own the battlepass")
				player:Kick("You tried to claim a battlepass reward without owning the battlepass, this results in exploiting, you've been banned from the experience")
			end
		end
	end

	if rewardType == "Freepass" then
		warn("Claiming freepass reward")
		if not seasonData.ClaimedLevels.Freepass[rewardLevel] then
			if #levelRewards.freepass > 0 then
				for index, rewardData in levelRewards.freepass do
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
						self._storeService.Client.CrateAddedSignal:Fire(
							player,
							rewardData.crateName,
							totalAmountOfCrates
						)
					end
					if rewardData.rewardType == BattlepassConfig.RewardTypes.Emote then
						self._dataService:AddEmote(player, rewardData.rewardEmote.name)
					end
				end
				table.insert(seasonData.ClaimedLevels.Freepass, rewardLevel)
			end
		end
	end

	self._dataService:SetKeyValue(player, "Battlepass", battlepassData)
end

--client claim reward function
function BattlepassService.Client:ClaimBattlepassReward(player: Player, rewardLevel: number, rewardType : string)
	warn(player, rewardLevel, rewardType)
	self.Server:ClaimBattlepassReward(player, rewardLevel, rewardType)
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
