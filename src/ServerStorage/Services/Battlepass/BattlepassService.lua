local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Constants
local SCALING_FACTOR = 1.05
local BASE_LEVEL_UP_XP = 1000
--Config
local BattlepassConfig = require(ReplicatedStorage.Source.Configurations.BattlepassConfig)
--Enum
local RewardsEnum = require(ReplicatedStorage.Source.Enums.RewardTypesEnum)

local BattlepassService = Knit.CreateService({
	Name = "BattlepassService",
	Client = {
		LevelUp = Knit.CreateSignal(),
		BattlepassExperienceAdded = Knit.CreateSignal(),
		BattlepassObtained = Knit.CreateSignal(),
	},
})

function BattlepassService:KnitStart()
	self._dataService = Knit.GetService("DataService")
	self._storeService = Knit.GetService("StoreService")
	self._currencyService = Knit.GetService("CurrencyService")
end

function BattlepassService:KnitInit() end

function BattlepassService:GetBattlepassData(player: Player)
	local battlepassData = self._dataService:GetKeyValue(player, "battlepass")
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
	local seasonExperience = battlepassData.experience
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
	--if it's premium reward check if the player has the battlepass
	if rewardType == "battlepass" then
		warn(rewardLevel)
		warn(table.find(seasonData.claimedLevels.battlepass, rewardLevel))

		if not table.find(seasonData.claimedLevels.battlepass, rewardLevel) then
			--Check if the player owns the battlepass
			if seasonData.owned then
				warn("Owns the battlepass")
				--Give the player the rewards
				for index, rewardData: table in levelRewards.battlepass do
					warn(rewardData)
					if
						rewardData.rewardType == RewardsEnum.RewardTypes.BattleCoins
						or rewardData.rewardType == RewardsEnum.RewardTypes.BattleGems
					then
						--Add currency
						warn("Adding currency")
						self._currencyService:AddCurrency(player, rewardData.rewardType, rewardData.rewardAmount)
					end
					if rewardData.rewardType == RewardsEnum.RewardTypes.Skin then
						--Add skin
						self._dataService:AddSkin(player, rewardData.rewardSkin.name)
					end
					if rewardData.rewardType == RewardsEnum.RewardTypes.Crate then
						--Add crate
						local totalAmountOfCrates = self._dataService:AddCrate(player, rewardData.crateName)
						--Fire the signal
						self._storeService.Client.CrateAddedSignal:Fire(
							player,
							rewardData.crateName,
							totalAmountOfCrates
						)
					end
					if rewardData.rewardType == RewardsEnum.RewardTypes.Emote then
						self._dataService:AddEmote(player, rewardData.rewardEmote.name, "Animation")
					end
					if rewardData.rewardType == RewardsEnum.RewardTypes.Emote_Icon then
						self._dataService:AddEmote(player, rewardData.rewardEmoteIcon.name, "Icon")
					end
					if rewardData.rewardType == RewardsEnum.RewardTypes.Weapon then
						self._dataService:AddWeapon(player, rewardData.weaponName)
					end
				end
				--If it hasn't been claimed the free reward claim it as well
				if not table.find(seasonData.claimedLevels.freepass, rewardLevel) then
					for index, rewardData in levelRewards.freepass do
						if
							rewardData.rewardType == RewardsEnum.RewardTypes.BattleCoins
							or rewardData.rewardType == RewardsEnum.RewardTypes.BattleGems
						then
							--Add currency
							self._currencyService:AddCurrency(player, rewardData.rewardType, rewardData.rewardAmount)
						end
						if rewardData.rewardType == RewardsEnum.RewardTypes.Skin then
							--Add skin
							self._dataService:AddSkin(player, rewardData.rewardSkin.name)
						end
						if rewardData.rewardType == RewardsEnum.RewardTypes.Crate then
							--Add crate
							local totalAmountOfCrates = self._dataService:AddCrate(player, rewardData.crateName)
							--Fire the signal
							self._storeService.Client.CrateAddedSignal:Fire(
								player,
								rewardData.crateName,
								totalAmountOfCrates
							)
						end
						if rewardData.rewardType == RewardsEnum.RewardTypes.Emote then
							self._dataService:AddEmote(player, rewardData.rewardEmote.name, "Animation")
						end
						if rewardData.rewardType == RewardsEnum.RewardTypes.Emote_Icon then
							self._dataService:AddEmote(player, rewardData.rewardEmoteIcon.name, "Icon")
						end
						if rewardData.rewardType == RewardsEnum.RewardTypes.Weapon then
							self._dataService:AddWeapon(player, rewardData.weaponName)
						end
					end
				end
				table.insert(seasonData.claimedLevels.battlepass, rewardLevel)
				table.insert(seasonData.claimedLevels.freepass, rewardLevel)
			else
				warn("Doesn't own the battlepass")
				player:Kick(
					"You tried to claim a battlepass reward without owning the battlepass, this results in exploiting, you've been banned from the experience"
				)
			end
		end
	end

	if rewardType == "freepass" then
		warn("Claiming freepass reward")
		if not table.find(seasonData.claimedLevels.freepass, rewardLevel) then
			if #levelRewards.freepass > 0 then
				for index, rewardData in levelRewards.freepass do
					if
						rewardData.rewardType == RewardsEnum.RewardTypes.BattleCoins
						or rewardData.rewardType == RewardsEnum.RewardTypes.BattleGems
					then
						--Add currency
						self._currencyService:AddCurrency(player, rewardData.rewardType, rewardData.rewardAmount)
					end
					if rewardData.rewardType == RewardsEnum.RewardTypes.Skin then
						--Add skin
						self._dataService:AddSkin(player, rewardData.rewardSkin.name)
					end
					if rewardData.rewardType == RewardsEnum.RewardTypes.Crate then
						--Add crate
						local totalAmountOfCrates = self._dataService:AddCrate(player, rewardData.crateName)
						--Fire the signal
						self._storeService.Client.CrateAddedSignal:Fire(
							player,
							rewardData.crateName,
							totalAmountOfCrates
						)
					end
					if rewardData.rewardType == RewardsEnum.RewardTypes.Emote then
						self._dataService:AddEmote(player, rewardData.rewardEmote.name, "Animation")
					end
					if rewardData.rewardType == RewardsEnum.RewardTypes.Emote_Icon then
						self._dataService:AddEmote(player, rewardData.rewardEmoteIcon.name, "Icon")
					end
				end
				table.insert(seasonData.claimedLevels.freepass, rewardLevel)
			end
		end
	end

	self._dataService:SetKeyValue(player, "battlepass", battlepassData)
end

--client claim reward function
function BattlepassService.Client:ClaimBattlepassReward(player: Player, rewardLevel: number, rewardType: string)
	warn(player, rewardLevel, rewardType)
	self.Server:ClaimBattlepassReward(player, rewardLevel, rewardType)
end

function BattlepassService:AddBattlepassExperience(player, amount: number)
	local battlepassData = self._dataService:GetKeyValue(player, "battlepass")
	local currentSeasonData = battlepassData[battlepassData.currentSeason]
	local maxLevel = BattlepassConfig.seasons[battlepassData.currentSeason].maxLevel
	local experienceToAdd = amount

	if currentSeasonData.level >= maxLevel then
		-- Player has reached max level, so we don't add more experience
		return
	end

	while experienceToAdd > 0 and currentSeasonData.level < maxLevel do
		local xpNeeded = self:GetExperienceNeededForNextLevel(player)
		local experienceGap = xpNeeded - currentSeasonData.experience
		if experienceToAdd >= experienceGap then
			currentSeasonData.level += 1
			-- Prevent leveling up beyond max level
			if currentSeasonData.level >= maxLevel then
				currentSeasonData.level = maxLevel
				currentSeasonData.experience = 0 -- Assuming we reset experience at max level
				self.Client.LevelUp:Fire(player, currentSeasonData.level)
				break -- Stop processing as we've reached max level
			else
				experienceToAdd -= experienceGap
				currentSeasonData.experience = 0
				self.Client.LevelUp:Fire(player, currentSeasonData.level)
			end
		else
			currentSeasonData.experience += experienceToAdd
			experienceToAdd = 0
		end
		self.Client.BattlepassExperienceAdded:Fire(player, currentSeasonData)
	end
end

function BattlepassService:GetExperienceNeededForNextLevel(player)
	local battlepassData = self._dataService:GetKeyValue(player, "battlepass")
	local currentSeasonData = battlepassData[battlepassData.currentSeason]
	local xpNeeded = BASE_LEVEL_UP_XP + (BASE_LEVEL_UP_XP * SCALING_FACTOR * (currentSeasonData.level - 1))
	return xpNeeded
end

function BattlepassService:CheckLevelUp(player)
	local battlepassData = self._dataService:GetKeyValue(player, "battlepass")
	local currentSeasonData = battlepassData[battlepassData.currentSeason]
	local xpNeeded = self:GetExperienceNeededForNextLevel(player)
	warn("experience needed", xpNeeded, "current experience", battlepassData.experience)
	if currentSeasonData.experience >= xpNeeded then
		currentSeasonData.level += 1
		currentSeasonData.experience = 0
		self.Client.LevelUp:Fire(player, currentSeasonData.level)
	end
end

function BattlepassService.Client:GetExperienceNeededForNextLevel(player: Player)
	return self.Server:GetExperienceNeededForNextLevel(player)
end

function BattlepassService.Client:BuyBattlepass(player: Player)
	local battlepassData = self.Server:GetBattlepassData(player)
	MarketplaceService:PromptProductPurchase(
		player,
		BattlepassConfig.seasonDevProdctsDictionary[battlepassData.currentSeason]
	)
end

function BattlepassService:GiftBattlepass(gifter, recipientId, season)
	-- Call the GiftBattlepass function of StoreService
	local success = self._storeService:GiftBattlepass(gifter, recipientId, season)

	-- Return the result
	return success
end

function BattlepassService.Client:GiftBattlepass(gifter: Player, recipientId: string, season: number)
	self.Server:GiftBattlepass(gifter, recipientId, season)
end

return BattlepassService
