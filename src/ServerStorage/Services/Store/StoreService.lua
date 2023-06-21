local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local StoreService = Knit.CreateService({
	Name = "StoreService",
	Client = {
		CratePurchaseSignal = Knit.CreateSignal(),
		OpenCrateSignal = Knit.CreateSignal(),
	},
})

StoreService.skins = {
	["Alter-Ego"] = "rbxassetid://13643596771",
	Venomus = "rbxassetid://358113752",
	["All-Seeing Eye"] = "rbxassetid://358279560",
	["Abstract Peach"] = "rbxassetid://13655041050",
	["Royal Ornate"] = "rbxassetid://13620123374",
	Pineapple = "rbxassetid://13655576502",
	Duckies = "rbxassetid://358413518",
	Totopos = "rbxassetid://358284720",
	["Digital Disturbance"] = "rbxassetid://358113994",
	Connections = "rbxassetid://358209640",
	["Party Time"] = "rbxassetid://358113881",
	Cherries = "rbxassetid://13662981938",
	Steampunk = "rbxassetid://13663622687",
	Darkness = "rbxassetid://13664411385",
	["Void Scars"] = "rbxassetid://13664464931",
	Constellation = "rbxassetid://13664532889",
	Bowies = "rbxassetid://13664668442",
	["Industrial Space"] = "rbxassetid://13664822366",
	["Coffins & Skulls"] = "rbxassetid://13665000362",
	["Rainbow Bats"] = "rbxassetid://13664947705",
	["Sugar-Haze"] = "rbxassetid://13665979274",
	["Forest Camo"] = "rbxassetid://13666123351",
	["Snow Camo"] = "rbxassetid://13667523981",
	["Desert Camo"] = "rbxassetid://13667570547",
	["Shark Camo"] = "rbxassetid://13667632021",
	["Punk Spirit"] = "rbxassetid://13667613116",
	["Ghost Camo"] = "rbxassetid://13667665573",
	Kraken = "rbxassetid://390097022",
	["Monkey Rage"] = "rbxassetid://13667787552",
	Dragonfruits = "rbxassetid://13667938944",
}

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
		Contents = {
			[1] = {
				Name = "Alter-Ego",
				Price = 100,
				Type = "Skin",
				Rarity = "Rare",
				Skin = "rbxassetid://13643596771",
				Id = "AlterEgo",
			},
			[2] = {
				Name = "Venomus",
				Price = 100,
				Type = "Skin",
				Rarity = "Mythic",
				Skin = "rbxassetid://358113752",
				Id = "Venomus",
			},
			[3] = {
				Name = "All-Seeing Eye",
				Price = 100,
				Type = "Skin",
				Rarity = "Mythic",
				Skin = "rbxassetid://358279560",

				Id = 3,
			},
			[4] = {
				Name = "Abstract Peach",
				Price = 100,
				Type = "Skin",
				Rarity = "Legendary",
				Skin = "rbxassetid://13655041050",

				Id = 4,
			},
			[5] = {
				Name = "Royal Ornate",
				Price = 100,
				Type = "Skin",
				Rarity = "Epic",
				Skin = "rbxassetid://13620123374",

				Id = 5,
			},
			[6] = {
				Name = "Pineapple",
				Price = 100,
				Type = "Skin",
				Rarity = "Common",
				Skin = "rbxassetid://13655576502",

				Id = 6,
			},
			[7] = {
				Name = "Duckies",
				Price = 100,
				Type = "Skin",
				Rarity = "Common",
				Skin = "rbxassetid://358413518",

				Id = 7,
			},
			[8] = {
				Name = "Totopos",
				Price = 100,
				Type = "Skin",
				Rarity = "Rare",
				Skin = "rbxassetid://358284720",

				Id = 8,
			},
			[9] = {
				Name = "Digital Disturbance",
				Price = 100,
				Type = "Skin",
				Rarity = "Epic",
				Skin = "rbxassetid://358113994",

				Id = 9,
			},
			[10] = {
				Name = "Connections",
				Price = 100,
				Type = "Skin",
				Rarity = "Epic",
				Skin = "rbxassetid://358209640",

				Id = 9,
			},
			[11] = {
				Name = "Party Time",
				Price = 100,
				Type = "Skin",
				Rarity = "Rare",
				Skin = "rbxassetid://358113881",

				Id = 9,
			},
			[12] = {
				Name = "Cherries",
				Price = 100,
				Type = "Skin",
				Rarity = "Common",
				Skin = "rbxassetid://13662981938",

				Id = 9,
			},
			[13] = {
				Name = "Steampunk",
				Price = 100,
				Type = "Skin",
				Rarity = "Rare",
				Skin = "rbxassetid://13663622687",

				Id = 9,
			},
			[14] = {
				Name = "Darkness",
				Price = 100,
				Type = "Skin",
				Rarity = "Common",
				Skin = "rbxassetid://13664411385",

				Id = 9,
			},
			[15] = {
				Name = "Void Scars",
				Price = 100,
				Type = "Skin",
				Rarity = "Legendary",
				Skin = "rbxassetid://13664464931",

				Id = 9,
			},
			[16] = {
				Name = "Constellation",
				Price = 100,
				Type = "Skin",
				Rarity = "Rare",
				Skin = "rbxassetid://13664532889",

				Id = 9,
			},
			[17] = {
				Name = "Bowies",
				Price = 100,
				Type = "Skin",
				Rarity = "Common",
				Skin = "rbxassetid://13664668442",

				Id = 9,
			},
			[18] = {
				Name = "Industrial Space",
				Price = 100,
				Type = "Skin",
				Rarity = "Rare",
				Skin = "rbxassetid://13664822366",

				Id = 9,
			},
			[19] = {
				Name = "Coffins & Skulls",
				Price = 100,
				Type = "Skin",
				Rarity = "Epic",
				Skin = "rbxassetid://13665000362",

				Id = 9,
			},
			[20] = {
				Name = "Rainbow Bats",
				Price = 100,
				Type = "Skin",
				Rarity = "Rare",
				Skin = "rbxassetid://13664947705",

				Id = 9,
			},
			[21] = {
				Name = "Sugar-Haze",
				Price = 100,
				Type = "Skin",
				Rarity = "Epic",
				Skin = "rbxassetid://13665979274",

				Id = 9,
			},
			[22] = {
				Name = "Forest Camo",
				Price = 100,
				Type = "Skin",
				Rarity = "Common",
				Skin = "rbxassetid://13666123351",

				Id = 9,
			},
			[23] = {
				Name = "Snow Camo",
				Price = 100,
				Type = "Skin",
				Rarity = "Common",
				Skin = "rbxassetid://13667523981",

				Id = 9,
			},
			[24] = {
				Name = "Desert Camo",
				Price = 100,
				Type = "Skin",
				Rarity = "Common",
				Skin = "rbxassetid://13667570547",

				Id = 9,
			},
			[25] = {
				Name = "Shark Camo",
				Price = 100,
				Type = "Skin",
				Rarity = "Epic",
				Skin = "rbxassetid://13667632021",

				Id = 9,
			},
			[26] = {
				Name = "Punk Spirit",
				Price = 100,
				Type = "Skin",
				Rarity = "Legendary",
				Skin = "rbxassetid://13667613116",

				Id = 9,
			},
			[27] = {
				Name = "Ghost Camo",
				Price = 100,
				Type = "Skin",
				Rarity = "Legendary",
				Skin = "rbxassetid://13667665573",

				Id = 9,
			},
			[28] = {
				Name = "Kraken",
				Price = 100,
				Type = "Skin",
				Rarity = "Mythic",
				Skin = "rbxassetid://390097022",

				Id = 9,
			},
			[29] = {
				Name = "Monkey Rage",
				Price = 100,
				Type = "Skin",
				Rarity = "Legendary",
				Skin = "rbxassetid://13667787552",
			},
			[30] = {
				Name = "Dragonfruits",
				Price = 100,
				Type = "Skin",
				Rarity = "Rare",
				Skin = "rbxassetid://13667938944",
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
	["Knockout_Effects_Crate"] = {
		Price = 100,
		Currency = "BattleGems",
		Contents = {
			[1] = {
				Name = "Knockout Effect 1",
				Price = 100,
				Type = "Knockout Effect",
				Rarity = "Common",
				Image = "rbxassetid://0",
				Description = "This is a knockout effect",
				Id = 1,
			},
			[2] = {
				Name = "Knockout Effect 2",
				Price = 100,
				Type = "Knockout Effect",
				Rarity = "Common",
				Image = "rbxassetid://0",
				Description = "This is a knockout effect",
				Id = 2,
			},
			[3] = {
				Name = "Knockout Effect 3",
				Price = 100,
				Type = "Knockout Effect",
				Rarity = "Common",
				Image = "rbxassetid://0",
				Description = "This is a knockout effect",
				Id = 3,
			},
			[4] = {
				Name = "Knockout Effect 4",
				Price = 100,
				Type = "Knockout Effect",
				Rarity = "Common",
				Image = "rbxassetid://0",
				Description = "This is a knockout effect",
				Id = 4,
			},
			[5] = {
				Name = "Knockout Effect 5",
				Price = 100,
				Type = "Knockout Effect",
				Rarity = "Common",
				Image = "rbxassetid://0",
				Description = "This is a knockout effect",
				Id = 5,
			},
			[6] = {
				Name = "Knockout Effect 6",
				Price = 100,
				Type = "Knockout Effect",
				Rarity = "Common",
				Image = "rbxassetid://0",
				Description = "This is a knockout effect",
				Id = 6,
			},
			[7] = {
				Name = "Knockout Effect 7",
				Price = 100,
				Type = "Knockout Effect",
				Rarity = "Common",
				Image = "rbxassetid://0",
				Description = "This is a knockout effect",
				Id = 7,
			},
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
}

function StoreService:KnitStart()
	--Services
	self._currencyService = Knit.GetService("CurrencyService")
	self._dataService = Knit.GetService("DataService")
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
	local bundle = self.bundles[bundleCategory][bundleName]
	if bundle then
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
		self.Client.CratePurchaseSignal:Fire(player, crateName, totalAmountOfCrates)
	end
end

--[Client] Buy crate function
function StoreService.Client:BuyCrate(player, crateName: string)
	return self.Server:BuyCrate(player, crateName)
end

--Open crate function
function StoreService:OpenCrate(player, crateName: string)
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
	for crateName, crateData in crate.Contents do
		if crateData.Rarity == rarityChosen then
			--assign the reward to the player
			if crateData.Type == "Skin" then
				rewardChosen = crateData
				warn(rewardChosen.Name)
				self._dataService:AddSkin(player, crateData.Name)
			end
			break
		end
	end

	--Remove crate from player's inventory
	local cratesLeft = self._dataService:RemoveCrate(player, crateName, true)
	--Fire the signal
	self.Client.OpenCrateSignal:Fire(player, crate, rewardChosen, cratesLeft, crateName)
end

--[Client] Open crate function
function StoreService.Client:OpenCrate(player, crateName: string)
	return self.Server:OpenCrate(player, crateName)
end

return StoreService
