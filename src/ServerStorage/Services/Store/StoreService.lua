--Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Assets
local Skins = require(ReplicatedStorage.Source.Assets.Skins)
local Emotes = require(ReplicatedStorage.Source.Assets.Emotes)
local EmoteIcons = require(ReplicatedStorage.Source.Assets.EmoteIcons)
--Modules
local TableUtil = require(ReplicatedStorage.Source.Modules.Util.TableUtil)
--Enums
local RaritiesEnum = require(ReplicatedStorage.Source.Enums.RaritiesEnum)
local ItemTypesEnum = require(ReplicatedStorage.Source.Enums.ItemTypesEnum)

--Config
local StoreConfig = require(ReplicatedStorage.Source.Configurations.StoreConfig)

local StoreService = Knit.CreateService({
	Name = "StoreService",
	Client = {
		CrateAddedSignal = Knit.CreateSignal(),
		OpenCrateSignal = Knit.CreateSignal(),
		BattlepassBoughtSignal = Knit.CreateSignal(),
		UpdateFeaturedItemsSignal = Knit.CreateSignal(),
		UpdateDailyItemsSignal = Knit.CreateSignal(),
		InsufficientFundsSignal = Knit.CreateSignal(),
	},
})

StoreService.bundles = {
	["Starter_Bundle"] = {
		price = 160,
		rewards = {
			BattleCoins = 3500,
			BattleGems = 1200,
			Skins_Crate = 1,
		},
	},
	["BattleCoins_Bundles"] = {
		Small = {
			price = 73,
			BattleCoins = 1500,
			layoutOrder = 1,
			ProductID = 1554784963,
		},
		Medium = {
			price = 146,
			BattleCoins = 3000,
			layoutOrder = 2,
			ProductID = 1554789006,
		},
		Large = {
			price = 292,
			BattleCoins = 6000,
			layoutOrder = 3,
			ProductID = 1554789422,
		},
		Huge = {
			price = 584,
			BattleCoins = 12000,
			layoutOrder = 4,
			ProductID = 1554789640,
		},
		Gigantic = {
			price = 1168,
			BattleCoins = 24000,
			layoutOrder = 5,
			ProductID = 1554789904,
		},
		Astronomic = {
			price = 2336,
			BattleCoins = 48000,
			layoutOrder = 6,
			ProductID = 1554790086,
		},
	},
	["BattleGems_Bundles"] = {
		Small = {
			price = 73,
			BattleGems = 500,
			layoutOrder = 1,
			ProductID = 1555198702,
		},
		Medium = {
			price = 146,
			BattleGems = 1000,
			layoutOrder = 2,
			ProductID = 1555199480,
		},
		Large = {
			price = 292,
			BattleGems = 2000,
			layoutOrder = 3,
			ProductID = 1555200039,
		},
		Huge = {
			price = 584,
			BattleGems = 4000,
			layoutOrder = 4,
			ProductID = 1555200879,
		},
		Gigantic = {
			price = 1168,
			BattleGems = 8000,
			layoutOrder = 5,
			ProductID = 1555201413,
		},
		Astronomic = {
			price = 2336,
			BattleGems = 16000,
			layoutOrder = 6,
			ProductID = 1555202235,
		},
	},
}

StoreService.crates = {
	["Skins_Crate"] = {
		Price = 350,
		Currency = "BattleGems",
		Type = "Skin",
		Contents = {
			[1] = Skins.AlterEgo,
			[2] = Skins.Venomus,
			[3] = Skins.AllSeeingEye,
			[4] = Skins.AbstractPeach,
			[5] = Skins.RoyalOrnate,
			[6] = Skins.Pineapple,
			[7] = Skins.Duckies,
			[8] = Skins.Totopos,
			[9] = Skins.DigitalDisturbance,
			[10] = Skins.Connections,
			[11] = Skins.PartyTime,
			[12] = Skins.Cherries,
			[13] = Skins.Steampunk,
			[14] = Skins.Darkness,
			[15] = Skins.VoidScars,
			[16] = Skins.Constellation,
			[17] = Skins.Bowies,
			[18] = Skins.IndustrialSpace,
			[19] = Skins.CoffinsSkulls,
			[20] = Skins.RainbowBats,
			[21] = Skins.SugarHaze,
			[22] = Skins.ForestCamo,
			[23] = Skins.SnowCamo,
			[24] = Skins.DesertCamo,
			[25] = Skins.SharkCamo,
			[26] = Skins.PunkSpirit,
			[27] = Skins.GhostCamo,
			[28] = Skins.Kraken,
			[29] = Skins.MonkeyRage,
			[30] = Skins.Dragonfruits,
			[31] = Skins.SpiderSense,
		},
		RaritiesPercentages = {
			Common = 70,
			Rare = 20,
			Epic = 5,
			Legendary = 4,
			Mythic = 1,
		},
	},
	["Starter_Crate"] = {
		Price = 160,
		Currency = "Robux",
		Color = Color3.fromRGB(165, 30, 30),
		rewards = {
			BattleCoins = 3500,
			BattleGems = 1200,
			Skins_Crate = 1,
		},
	},
	["Emotes_Crate"] = {
		Price = 100,
		Currency = "BattleGems",
		Type = "Emote",
		Color = Color3.fromRGB(30, 138, 165),
		Contents = {
			[1] = Emotes.Club_Dance,
			[2] = Emotes.Sleep,
			[3] = Emotes.Boneless,
			[4] = Emotes.Feet_Clap,
			[5] = Emotes.Dab,
			[6] = Emotes.Cosita,
			[7] = Emotes.The_Twist,
			[8] = Emotes.Zombiller,
			[9] = Emotes.Worming,
			[10] = Emotes.Hype,
			[11] = Emotes.Fresh,
			[12] = Emotes.Bandit_Dance,
			[13] = Emotes.Eagling
		},
		RaritiesPercentages = {
			Common = 70,
			Rare = 20,
			Epic = 5,
			Legendary = 4,
			Mythic = 1,
		},
	},
}

StoreService.prestigeItems = {
	Skins = {
		[1] = {
			price = 200,
			currency = "BattleGems",
			prestigeNeeded = 1,
			data = Skins.AllSeeingEye,
		},
		[2] = {
			price = 2_000,
			currency = "BattleGems",
			prestigeNeeded = 2,
			data = Skins.MayanFigures,
		},
	},
	
	Emotes = {
		[1] = {
			price = 200,
			currency = "BattleGems",
			prestigeNeeded = 3,
			data = Emotes.Club_Dance,
		},
	},
}

function StoreService:KnitStart()
	--Services
	self._currencyService = Knit.GetService("CurrencyService")
	self._dataService = Knit.GetService("DataService")
	self._battlepassService = Knit.GetService("BattlepassService")
	--Variables
	self._featuredItems = {}
	self._dailyItems = {}
	--Initialize timed items
	self:InitializeTimedItems()
	--Developer products
	local productFunctions = {}
	--BattleCoins

	-- ProductId 1554784963 small
	productFunctions[1554784963] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleCoins", 1500)
	end

	--ProductId 1554789006 medium (3k)
	productFunctions[1554789006] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleCoins", 3000)
	end

	--ProductId 1554789422 large (6k)
	productFunctions[1554789422] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleCoins", 6000)
	end

	--ProductId 1554789640 huge (12k)
	productFunctions[1554789640] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleCoins", 12000)
	end

	--ProductId 1554789904 gigantic (24k)
	productFunctions[1554789904] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleCoins", 24000)
	end

	--ProductId 1554790086 astronomic (48k)
	productFunctions[1554790086] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleCoins", 48000)
	end

	--BattleGems
	--ProductId 1555198702 small (500)
	productFunctions[1555198702] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleGems", 500)
	end
	--ProductId 1555199480 medium (1k)
	productFunctions[1555199480] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleGems", 1000)
	end
	--ProductId 1555200039 large (2k)
	productFunctions[1555200039] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleGems", 2000)
	end
	--ProductId 1555200879 huge (4k)
	productFunctions[1555200879] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleGems", 4000)
	end
	--ProductId 1555201413 gigantic (8k)
	productFunctions[1555201413] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleGems", 8000)
	end
	--ProductId 1555202235 astronomic (16k)
	productFunctions[1555202235] = function(receipt, player)
		return self._currencyService:AddCurrency(player, "BattleGems", 16000)
	end

	--Battlepass seasons
	--ProductId 1532101515 Season 1
	productFunctions[1532101515] = function(receipt, player)
		local battlepassData = self._dataService:GetKeyValue(player, "Battlepass")
		battlepassData.Season_1.Owned = true
		self._dataService:SetKeyValue(player, "Battlepass", battlepassData)
		self._battlepassService.Client.BattlepassObtained:Fire(player)
		self.Client.BattlepassBoughtSignal:Fire(player)
		return true
	end

	local function processReceipt(receiptInfo)
		local userId = receiptInfo.PlayerId
		local productId = receiptInfo.ProductId

		local player = Players:GetPlayerByUserId(userId)
		if player then
			-- Get the handler function associated with the developer product ID and attempt to run it
			local handler = productFunctions[productId]
			local success, result = pcall(handler, receiptInfo, player)
			if success then
				-- The user has received their benefits!
				-- return PurchaseGranted to confirm the transaction.
				return Enum.ProductPurchaseDecision.PurchaseGranted
			else
				warn("Failed to process receipt:", receiptInfo, result)
			end
		end

		-- the user's benefits couldn't be awarded.
		-- return NotProcessedYet to try again next time the user joins.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	-- Set the callback; this can only be done once by one script on the server!
	MarketplaceService.ProcessReceipt = processReceipt
end

function StoreService:KnitInit() end

local function getInsertCountBasedOnRarity(rarity)
	if rarity == RaritiesEnum.Common then
		return 5
	elseif rarity == RaritiesEnum.Rare then
		return 4
	elseif rarity == RaritiesEnum.Epic then
		return 1
	elseif rarity == RaritiesEnum.Legendary then
		return 1
	elseif rarity == RaritiesEnum.Mythic then
		return 1
	end
end

function StoreService:InitializeTimedItems()
	self:UpdateFeaturedItems()
	task.spawn(function()
		while true do
			task.wait(StoreConfig.REFRESH_RATE)
			self:UpdateFeaturedItems()
		end
	end)
	self:UpdateDailyItems()
	task.spawn(function()
		while true do
			task.wait(StoreConfig.REFRESH_RATE)
			self:UpdateDailyItems()
		end
	end)
end

function StoreService:UpdateFeaturedItems()
	self._featuredItems = self:GetFeaturedItems()
	-- warn(self._featuredItems)
	self.Client.UpdateFeaturedItemsSignal:FireAll(self._featuredItems)
end

function StoreService:GetFeaturedItems()
	local skinsForSale = {}
	local emotesForSale = {}

	for index, skinData in pairs(Skins) do
		local insertCount = getInsertCountBasedOnRarity(skinData.rarity)
		for i = 1, insertCount do
			local skinItem = { _type = ItemTypesEnum.Skin, data = skinData }
			if not TableUtil.tableContainsValue(self._dailyItems, skinItem) then
				skinsForSale[#skinsForSale + 1] = skinItem
			end
		end
	end

	for index, emoteData in pairs(Emotes) do
		local insertCount = getInsertCountBasedOnRarity(emoteData.rarity)
		for i = 1, insertCount do
			local emoteItem = { _type = ItemTypesEnum.Emote, data = emoteData }
			if not TableUtil.tableContainsValue(self._dailyItems, emoteItem) then
				emotesForSale[#emotesForSale + 1] = emoteItem
			end
		end
	end

	local timeNow = os.time() + StoreConfig.RESET_TIME_OFFSET

	-- update the shops every UPDATE_RATE seconds
	local skinsIndex = math.floor((timeNow / StoreConfig.FEATURED_ITEMS_UPDATE_RATE) % #skinsForSale)
	local emotesIndex = math.floor((timeNow / StoreConfig.FEATURED_ITEMS_UPDATE_RATE + 1) % #emotesForSale)

	if skinsIndex == 0 then
		skinsIndex = #skinsForSale
	end

	if emotesIndex == 0 then
		emotesIndex = #emotesForSale
	end

	local featuredItems = {
		skinsForSale[skinsIndex],
		emotesForSale[emotesIndex],
	}

	return featuredItems
end

function StoreService:UpdateDailyItems()
	self._dailyItems = self:GetDailyItems()
	-- warn(self._dailyItems)
	self.Client.UpdateDailyItemsSignal:FireAll(self._dailyItems)
end

function StoreService:GetDailyItems()
	local dailyItems = {}
	local timeNow = os.time() + StoreConfig.RESET_TIME_OFFSET
	local itemsForSale = {}

	-- Combine all items into one table
	for index, skinData in pairs(Skins) do
		local insertCount = getInsertCountBasedOnRarity(skinData.rarity)
		for i = 1, insertCount do
			table.insert(itemsForSale, { _type = ItemTypesEnum.Skin, data = skinData })
		end
	end

	for index, emoteData in pairs(Emotes) do
		local insertCount = getInsertCountBasedOnRarity(emoteData.rarity)
		for i = 1, insertCount do
			table.insert(itemsForSale, { _type = ItemTypesEnum.Emote, data = emoteData })
		end
	end

	for index, emoteIconData in pairs(EmoteIcons) do
		local insertCount = getInsertCountBasedOnRarity(emoteIconData.rarity)
		for i = 1, insertCount do
			if emoteIconData.forSale == nil or emoteIconData.forSale == true then
				table.insert(itemsForSale, { _type = ItemTypesEnum.EmoteIcon, data = emoteIconData })
			end
		end
	end

	-- Calculate the index for each daily item
	if #itemsForSale > 0 then
		local skinCount = 0
		local emoteCount = 0
		local emoteIconCount = 0
		local i = 1
		while #dailyItems < StoreConfig.DAILY_ITEMS_NUM and i <= #itemsForSale * StoreConfig.DAILY_ITEMS_NUM do
			local index = math.floor((timeNow / StoreConfig.DAILY_ITEMS_UPDATE_RATE + i) % #itemsForSale)
			if index == 0 then
				index = #itemsForSale
			end

			-- Check for item type limits
			if
				not TableUtil.tableContainsValue(dailyItems, itemsForSale[index])
				and not TableUtil.tableContainsValue(self._featuredItems, itemsForSale[index])
			then
				if
					itemsForSale[index]._type == ItemTypesEnum.Skin
					and skinCount < StoreConfig.DailyItemTypesLimit.Skin
				then
					table.insert(dailyItems, itemsForSale[index])
					skinCount = skinCount + 1
				elseif
					itemsForSale[index]._type == ItemTypesEnum.Emote
					and emoteCount < StoreConfig.DailyItemTypesLimit.Emote
				then
					table.insert(dailyItems, itemsForSale[index])
					emoteCount = emoteCount + 1
				elseif
					itemsForSale[index]._type == ItemTypesEnum.EmoteIcon
					and emoteIconCount < StoreConfig.DailyItemTypesLimit.EmoteIcon
				then
					table.insert(dailyItems, itemsForSale[index])
					emoteIconCount = emoteIconCount + 1
				end
			end

			i += 1
		end
	end

	return dailyItems
end

function StoreService:GetPrestigeItems()
	return self.prestigeItems
end

function StoreService.Client:GetPrestigeItems()
	return self.Server:GetPrestigeItems()
end

function StoreService.Client:GetFeaturedItems()
	return self.Server:GetFeaturedItems()
end

function StoreService.Client:GetDailyItems()
	return self.Server:GetDailyItems()
end

--Get bundles function
function StoreService:GetBundles(bundleCategory: string)
	if bundleCategory then
		return self.bundles[bundleCategory]
	end
	return self.bundles
end
--[Client] Get bundles function
function StoreService.Client:GetBundles(player, bundleCategory: string)
	return self.Server:GetBundles(bundleCategory)
end

--Buy bundle function
function StoreService:PurchaseBundle(player, bundleCategory: string, bundleName: string)
	warn(player, bundleName, bundleCategory)
	local bundle = self.bundles[bundleCategory][bundleName]
	local success, result = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(player)
	end)

	if not success then
		warn("PolicyService error: " .. result)
		return
	elseif result.ArePaidRandomItemsRestricted then
		warn("Player cannot interact with paid random item generators")
		return
	end
	if bundle and success then
		MarketplaceService:PromptProductPurchase(player, bundle.ProductID)
	end
	return false
end

function StoreService:GiftBattlepass(gifter, recipientId, season)
	-- Check if the recipient is in the game
	local recipient = Players:GetPlayerByUserId(recipientId)
	if not recipient then
		warn("Recipient is not in the game")
		return false
	end
	-- Check if the recipient already owns the battlepass for the specified season
	local recipientBattlepassData = self._dataService:GetKeyValue(recipient, "Battlepass")
	if recipientBattlepassData[season].Owned then
		warn("Recipient already owns the battlepass for this season")
		return false
	end

	-- Gift the battlepass
	recipientBattlepassData[season].Owned = true
	self._dataService:SetKeyValue(recipient, "Battlepass", recipientBattlepassData)
	self._battlepassService.Client.BattlepassObtained:Fire(recipient)
	self.Client.BattlepassGiftedSignal:Fire(gifter, recipient)

	return true
end

--[Client] Buy bundle function
function StoreService.Client:PurchaseBundle(player, bundleCategory: string, bundleName: string)
	return self.Server:PurchaseBundle(player, bundleCategory, bundleName)
end

--Get crates function
function StoreService:GetCrates()
	return self.crates
end

--[Client] Get crates function
function StoreService.Client:GetCrates()
	return self.Server:GetCrates()
end

--Buy crate function
function StoreService:PurchaseCrate(player, crateName: string)
	local crate = self.crates[crateName]
	--Get currency
	local currentCurrency = self._currencyService:GetCurrency(player, crate.Currency)
	if currentCurrency >= crate.Price then
		--Remove currency
		self._currencyService:RemoveCurrency(player, crate.Currency, crate.Price)
		--Add crate to player's inventory
		local totalAmountOfCrates = self._dataService:AddCrate(player, crateName, true)
		--Fire the signal
		self.Client.CrateAddedSignal:Fire(player, crateName, totalAmountOfCrates)
	else
		self.Client.InsufficientFundsSignal:Fire(player, crate.Price, crate.Currency)
	end
end

--Purchase skin function
function StoreService:PurchaseSkin(player, skinName: string, currency: string?)
	--Get the skin data so the player doesn't have to send the whole skin data
	--remove spaces and dashes from the skin name
	skinName = skinName:gsub("%s+", ""):gsub("-", "")
	local skinData = Skins[skinName]
	local price = skinData.price
	local _currency = currency or skinData.currency
	local currentCurrency = self._currencyService:GetCurrency(player, _currency)
	if currentCurrency >= price then
		self._currencyService:RemoveCurrency(player, _currency, price)
		self._dataService:AddSkin(player, skinData.name)
		return true
	else
		self.Client.InsufficientFundsSignal:Fire(player, price, _currency)
		return false
	end
end

function StoreService:PurchaseEmote(player, emoteID: string, emoteType: string, currency: string?)
	--Get the emote data so the player doesn't have to send the whole emote data
	--Change spaces to underscores
	emoteID = emoteID:gsub("%s+", "_")
	local emoteData = Emotes[emoteID] or EmoteIcons[emoteID]
	local price = emoteData.price
	local _currency = currency or emoteData.currency
	warn(_currency)
	local currentCurrency = self._currencyService:GetCurrency(player, _currency)
	warn(currentCurrency, price)
	if currentCurrency >= price then
		self._currencyService:RemoveCurrency(player, _currency, price)
		self._dataService:AddEmote(player, emoteData.name, emoteType)
		warn("Emote purchased")
		return true
	else
		warn("Insufficient funds")
		self.Client.InsufficientFundsSignal:Fire(player, price, _currency)
		return false
	end
end

--[Client] Purchase emote function
function StoreService.Client:PurchaseEmote(player, emoteName: string, emoteType: string, currency: string)
	return self.Server:PurchaseEmote(player, emoteName, emoteType, currency)
end

--[Client] Purchase skin function
function StoreService.Client:PurchaseSkin(player, skinName: string, currency: string)
	return self.Server:PurchaseSkin(player, skinName, currency)
end

--[Client] Buy crate function
function StoreService.Client:PurchaseCrate(player, crateName: string)
	return self.Server:PurchaseCrate(player, crateName)
end

--Open crate function
function StoreService:OpenCrate(player, crateName: string, crateType: string)
	--check if the player has the crate
	if not self._dataService:HasCrate(player, crateName) then
		return nil
	end
	warn("[Store Service] opening crate: " .. crateName)
	local n = 0
	local rarityChosen = nil
	local crate = self.crates[crateName]
	local rnd = Random.new()
	local plrChance = rnd:NextNumber() * 100

	for rarityName, value in crate.RaritiesPercentages do
		n += value
		if plrChance <= n then
			rarityChosen = rarityName
			break
		end
	end

	local rng = Random.new()

	local function shuffle<K, V>(from: { [K]: V }): { [K]: V }
		for i = #from, 2, -1 do
			local j = rng:NextInteger(1, i)
			from[i], from[j] = from[j], from[i]
		end
		return from
	end

	shuffle(crate.Contents)
	local rewardChosen
	for index, contentData: table in crate.Contents do
		if contentData.rarity == rarityChosen then
			--assign the reward to the player
			rewardChosen = contentData
			if crateType == "Skin" then
				self._dataService:AddSkin(player, contentData.name)
			end

			if crateType == "Emote" then
				self._dataService:AddEmote(player, contentData.name, "Animation")
			end
			break
		end
	end
	local unboxTime = math.random(3, 6)
	--Remove crate from player's inventory
	local cratesLeft = self._dataService:RemoveCrate(player, crateName, true)
	--Fire the signal
	warn(player, crate, rewardChosen, cratesLeft, crateName, unboxTime)
	self.Client.OpenCrateSignal:Fire(player, crate, rewardChosen, cratesLeft, crateName, unboxTime)
	return unboxTime
end

--[Client] Open crate function
function StoreService.Client:OpenCrate(player, crateName: string, crateType: string)
	return self.Server:OpenCrate(player, crateName, crateType)
end

return StoreService
