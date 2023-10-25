local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Assets
local Skins = require(ReplicatedStorage.Source.Assets.Skins)
local Emotes = require(ReplicatedStorage.Source.Assets.Emotes)


local StoreService = Knit.CreateService({
	Name = "StoreService",
	Client = {
		CrateAddedSignal = Knit.CreateSignal(),
		OpenCrateSignal = Knit.CreateSignal(),
		BattlepassBoughtSignal = Knit.CreateSignal()
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
			[1] = {
				Name = Skins.AlterEgo.name,
				Rarity = Skins.AlterEgo.rarity,
				Skin = Skins.AlterEgo.skinID,
			},
			[2] = {
				Name = Skins.Venomus.name,
				Rarity = Skins.Venomus.rarity,
				Skin = Skins.Venomus.skinID,
			},
			[3] = {
				Name = Skins.AllSeeingEye.name,
				Rarity = Skins.AllSeeingEye.rarity,
				Skin = Skins.AllSeeingEye.skinID,
			},
			[4] = {
				Name = Skins.AbstractPeach.name,
				Rarity = Skins.AbstractPeach.rarity,
				Skin = Skins.AbstractPeach.skinID,
			},
			[5] = {
				Name = Skins.RoyalOrnate.name,
				Rarity = Skins.RoyalOrnate.rarity,
				Skin = Skins.RoyalOrnate.skinID,
			},
			[6] = {
				Name = Skins.Pineapple.name,
				Rarity = Skins.Pineapple.rarity,
				Skin = Skins.Pineapple.skinID,
			},
			[7] = {
				Name = Skins.Duckies.name,
				Rarity = Skins.Duckies.rarity,
				Skin = Skins.Duckies.skinID,
			},
			[8] = {
				Name = Skins.Totopos.name,
				Rarity = Skins.Totopos.rarity,
				Skin = Skins.Totopos.skinID,
			},
			[9] = {
				Name = Skins.DigitalDisturbance.name,
				Rarity = Skins.DigitalDisturbance.rarity,
				Skin = Skins.DigitalDisturbance.skinID,
			},
			[10] = {
				Name = Skins.Connections.name,
				Rarity = Skins.Connections.rarity,
				Skin = Skins.Connections.skinID,
			},
			[11] = {
				Name = Skins.PartyTime.name,
				Rarity = Skins.PartyTime.rarity,
				Skin = Skins.PartyTime.skinID,
			},
			[12] = {
				Name = Skins.Cherries.name,
				Rarity = Skins.Cherries.rarity,
				Skin = Skins.Cherries.skinID,
			},
			[13] = {
				Name = Skins.Steampunk.name,
				Rarity = Skins.Steampunk.rarity,
				Skin = Skins.Steampunk.skinID,
			},
			[14] = {
				Name = Skins.Darkness.name,
				Rarity = Skins.Darkness.rarity,
				Skin = Skins.Darkness.skinID,
			},
			[15] = {
				Name = Skins.VoidScars.name,
				Rarity = Skins.VoidScars.rarity,
				Skin = Skins.VoidScars.skinID,
			},
			[16] = {
				Name = Skins.Constellation.name,
				Rarity = Skins.Constellation.rarity,
				Skin = Skins.Constellation.skinID,
			},
			[17] = {
				Name = Skins.Bowies.name,
				Rarity = Skins.Bowies.rarity,
				Skin = Skins.Bowies.skinID,
			},
			[18] = {
				Name = Skins.IndustrialSpace.name,
				Rarity = Skins.IndustrialSpace.rarity,
				Skin = Skins.IndustrialSpace.skinID,
			},
			[19] = {
				Name = Skins.CoffinsSkulls.name,
				Rarity = Skins.CoffinsSkulls.rarity,
				Skin = Skins.CoffinsSkulls.skinID,
			},
			[20] = {
				Name = Skins.RainbowBats.name,
				Rarity = Skins.RainbowBats.rarity,
				Skin = Skins.RainbowBats.skinID,
			},
			[21] = {
				Name = Skins.SugarHaze.name,
				Rarity = Skins.SugarHaze.rarity,
				Skin = Skins.SugarHaze.skinID,
			},
			[22] = {
				Name = Skins.ForestCamo.name,
				Rarity = Skins.ForestCamo.rarity,
				Skin = Skins.ForestCamo.skinID,
			},
			[23] = {
				Name = Skins.SnowCamo.name,
				Rarity = Skins.SnowCamo.rarity,
				Skin = Skins.SnowCamo.skinID,
			},
			[24] = {
				Name = Skins.DesertCamo.name,
				Rarity = Skins.DesertCamo.rarity,
				Skin = Skins.DesertCamo.skinID,
			},
			[25] = {
				Name = Skins.SharkCamo.name,
				Rarity = Skins.SharkCamo.rarity,
				Skin = Skins.SharkCamo.skinID,
			},
			[26] = {
				Name = Skins.PunkSpirit.name,
				Rarity = Skins.PunkSpirit.rarity,
				Skin = Skins.PunkSpirit.skinID,
			},
			[27] = {
				Name = Skins.GhostCamo.name,
				Rarity = Skins.GhostCamo.rarity,
				Skin = Skins.GhostCamo.skinID,
			},
			[28] = {
				Name = Skins.Kraken.name,
				Rarity = Skins.Kraken.rarity,
				Skin = Skins.Kraken.skinID,
			},
			[29] = {
				Name = Skins.MonkeyRage.name,
				Rarity = Skins.MonkeyRage.rarity,
				Skin = Skins.MonkeyRage.skinID,
			},
			[30] = {
				Name = Skins.Dragonfruits.name,
				Rarity = Skins.Dragonfruits.rarity,
				Skin = Skins.Dragonfruits.skinID,
			},
			[31] = {
				Name = Skins.SpiderSense.name,
				Rarity = Skins.SpiderSense.rarity,
				Skin = Skins.SpiderSense.skinID,
			},
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
			[1] = {
				Name = Emotes.Club_Dance.name,
				Rarity = Emotes.Club_Dance.rarity,
				EmoteAnimation = Emotes.Club_Dance.animation,
			},
			[2] = {
				Name = Emotes.Sleep.name,
				Rarity = Emotes.Sleep.rarity,
				EmoteAnimation = Emotes.Sleep.animation,
			},
			[3] = {
				Name = Emotes.Boneless.name,
				Rarity = Emotes.Boneless.rarity,
				EmoteAnimation = Emotes.Boneless.animation,
			},
			[4] = {
				Name = Emotes.Feet_Clap.name,
				Rarity = Emotes.Feet_Clap.rarity,
				EmoteAnimation = Emotes.Feet_Clap.animation,
			},
			[5] = {
				Name = Emotes.Dab.name,
				Rarity = Emotes.Dab.rarity,
				EmoteAnimation = Emotes.Dab.animation,
			},
			[6] = {
				Name = Emotes.Cosita.name,
				Rarity = Emotes.Cosita.rarity,
				EmoteAnimation = Emotes.Cosita.animation,
			},
			[7] = {
				Name = Emotes.The_Twist.name,
				Rarity = Emotes.The_Twist.rarity,
				EmoteAnimation = Emotes.The_Twist.animation,
			},
			[8] = {
				Name = Emotes.Zombiller.name,
				Rarity = Emotes.Zombiller.rarity,
				EmoteAnimation = Emotes.Zombiller.animation,
			},
			[9] = {
				Name = Emotes.Worming.name,
				Rarity = Emotes.Worming.rarity,
				EmoteAnimation = Emotes.Worming.animation,
			},
			[10] = {
				Name = Emotes.Hype.name,
				Rarity = Emotes.Hype.rarity,
				EmoteAnimation = Emotes.Hype.animation,
			},
			[11] = {
				Name = Emotes.Fresh.name,
				Rarity = Emotes.Fresh.rarity,
				EmoteAnimation = Emotes.Fresh.animation,
			},
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

function StoreService:KnitStart()
	--Services
	self._currencyService = Knit.GetService("CurrencyService")
	self._dataService = Knit.GetService("DataService")
	self._battlepassService = Knit.GetService("BattlepassService")
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

function StoreService:GetDailyItems() end

function StoreService.Client:GetDailyItems() end

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
function StoreService:BuyBundle(player, bundleCategory: string, bundleName: string)
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

--[Client] Buy bundle function
function StoreService.Client:BuyBundle(player, bundleCategory: string, bundleName: string)
	return self.Server:BuyBundle(player, bundleCategory, bundleName)
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
function StoreService:BuyCrate(player, crateName: string)
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
	end
end

--[Client] Buy crate function
function StoreService.Client:BuyCrate(player, crateName: string)
	return self.Server:BuyCrate(player, crateName)
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
		if contentData.Rarity == rarityChosen then
			--assign the reward to the player
			rewardChosen = contentData
			if crateType == "Skin" then
				self._dataService:AddSkin(player, contentData.Name)
			end

			if crateType == "Emote" then
				self._dataService:AddEmote(player, contentData.Name, "Animation")
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
