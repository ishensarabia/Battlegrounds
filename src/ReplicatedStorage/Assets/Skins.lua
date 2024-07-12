local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaritiesEnum = require(ReplicatedStorage.Source.Enums.RaritiesEnum)
local CurrenciesEnum = require(ReplicatedStorage.Source.Enums.CurrenciesEnum)
local skins = {
	AlterEgo = {
		skinID = "rbxassetid://13643596771",
		rarity = RaritiesEnum.Rare,
		name = "Alter-Ego",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Venomus = {
		skinID = "rbxassetid://358113752",
		rarity = RaritiesEnum.Mythic,
		name = "Venomus",
        price = 6_000,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	AllSeeingEye = {
		skinID = "rbxassetid://358279560",
		rarity = RaritiesEnum.Mythic,
		name = "All-Seeing Eye",
        price = 3_300,
        currency = "BattleGems",
        forSale = true
	},
	AbstractPeach = {
		skinID = "rbxassetid://13655041050",
		rarity = RaritiesEnum.Legendary,
		name = "Abstract Peach",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	RoyalOrnate = {
		skinID = "rbxassetid://13620123374",
		rarity = RaritiesEnum.Epic,
		name = "Royal Ornate",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Pineapple = {
		skinID = "rbxassetid://13655576502",
		rarity = RaritiesEnum.Common,
		name = "Pineapple",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Duckies = {
		skinID = "rbxassetid://358413518",
		rarity = RaritiesEnum.Common,
		name = "Duckies",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Totopos = {
		skinID = "rbxassetid://358284720",
		rarity = RaritiesEnum.Rare,
		name = "Totopos",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	DigitalDisturbance = {
		skinID = "rbxassetid://358113994",
		rarity = RaritiesEnum.Epic,
		name = "Digital Disturbance",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Connections = {
		skinID = "rbxassetid://358209640",
		rarity = RaritiesEnum.Epic,
		name = "Connections",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	PartyTime = {
		skinID = "rbxassetid://358113881",
		rarity = RaritiesEnum.Rare,
		name = "Party Time",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Cherries = {
		skinID = "rbxassetid://13662981938",
		rarity = RaritiesEnum.Common,
		name = "Cherries",
        price = 899,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Steampunk = {
		skinID = "rbxassetid://13663622687",
		rarity = RaritiesEnum.Rare,
		name = "Steampunk",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Darkness = {
		skinID = "rbxassetid://13664411385",
		rarity = RaritiesEnum.Common,
		name = "Darkness",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	VoidScars = {
		skinID = "rbxassetid://13664464931",
		rarity = RaritiesEnum.Legendary,
		name = "Void Scars",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Constellation = {
		skinID = "rbxassetid://13664532889",
		rarity = RaritiesEnum.Rare,
		name = "Constellation",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Bowies = {
		skinID = "rbxassetid://13664668442",
		rarity = RaritiesEnum.Common,
		name = "Bowies",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	IndustrialSpace = {
		skinID = "rbxassetid://13664822366",
		rarity = RaritiesEnum.Rare,
		name = "Industrial Space",
        price = 600,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	CoffinsSkulls = {
		skinID = "rbxassetid://13665000362",
		rarity = RaritiesEnum.Epic,
		name = "Coffins & Skulls",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	RainbowBats = {
		skinID = "rbxassetid://13664947705",
		rarity = RaritiesEnum.Rare,
		name = "Rainbow Bats",
        price = 2_000,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	SugarHaze = {
		skinID = "rbxassetid://13665979274",
		rarity = RaritiesEnum.Epic,
		name = "Sugar-Haze",
        price = 2_000,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	ForestCamo = {
		skinID = "rbxassetid://13666123351",
		rarity = RaritiesEnum.Common,
		name = "Forest Camo",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	SnowCamo = {
		skinID = "rbxassetid://13667523981",
		rarity = RaritiesEnum.Common,
		name = "Snow Camo",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	DesertCamo = {
		skinID = "rbxassetid://13667570547",
		rarity = RaritiesEnum.Common,
		name = "Desert Camo",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	SharkCamo = {
		skinID = "rbxassetid://13667632021",
		rarity = RaritiesEnum.Epic,
		name = "Shark Camo",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	PunkSpirit = {
		skinID = "rbxassetid://13667613116",
		rarity = RaritiesEnum.Legendary,
		name = "Punk Spirit",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	GhostCamo = {
		skinID = "rbxassetid://13667665573",
		rarity = RaritiesEnum.Legendary,
		name = "Ghost Camo",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Kraken = {
		skinID = "rbxassetid://390097022",
		rarity = RaritiesEnum.Mythic,
		name = "Kraken",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	MonkeyRage = {
		skinID = "rbxassetid://13667787552",
		rarity = RaritiesEnum.Legendary,
		name = "Monkey Rage",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Dragonfruits = {
		skinID = "rbxassetid://13667938944",
		rarity = RaritiesEnum.Rare,
		name = "Dragonfruits",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Melancoly = {
		skinID = "rbxassetid://13829565984",
		rarity = RaritiesEnum.Legendary,
		name = "Melancoly",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	MayanFigures = {
		skinID = "rbxassetid://13867946001",
		rarity = RaritiesEnum.Mythic,
		name = "Mayan Figures",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	SpiderSense = {
		skinID = "rbxassetid://13874149361",
		rarity = RaritiesEnum.Epic,
		name = "Spider Sense",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	SpiderSpirit = {
		skinID = "rbxassetid://13874336571",
		rarity = RaritiesEnum.Legendary,
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true,
		name = "Spider Spirit",
	},
	SkullRoses = {
		skinID = "rbxassetid://15021618982",
		rarity = RaritiesEnum.Epic,
		name = "Skull & Roses",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
	Tech = {
		skinID = "rbxassetid://15021666612",
		rarity = RaritiesEnum.Rare,
		name = "Tech",
        price = 200,
        currency = CurrenciesEnum.BattleCoins,
        forSale = true
	},
}

return skins
