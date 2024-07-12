local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrenciesEnum = require(ReplicatedStorage.Source.Enums.CurrenciesEnum)
return {
	Why_So_Afraid = {
		imageID = "rbxassetid://14066669168",
		rarity = "Common",
		name = "Why So Afraid",
		price = 200,
		currency = CurrenciesEnum.BattleCoins,
		forSale = false
	},
	Ghost = {
		imageID = "rbxassetid://14066775703",
		rarity = "Rare",
		name = "Ghost",
		price = 200,
		currency = CurrenciesEnum.BattleCoins,
	},
	Im_Fine_Skull = {
		imageID = "rbxassetid://14066952819",
		rarity = "Epic",
		name = "I'm Fine Skull",
		price = 200,
		currency = CurrenciesEnum.BattleCoins,
		forSale = false
	},
	Angry_Skull = {
		imageID = "rbxassetid://18433350306",
		rarity = "Epic",
		name = "Angry Skull",
		price = 200,
		currency = CurrenciesEnum.BattleCoins,
		forSale = true
	},
	GG = {
		imageID = "rbxassetid://18437018119",
		rarity = "Rare",
		name = "GG",
		price = 200,
		currency = CurrenciesEnum.BattleCoins,
		forSale = true
	},
	White_Flag = {
		imageID = "rbxassetid://18445514865",
		rarity = "Rare",
		name = "White Flag",
		price = 200,
		currency = CurrenciesEnum.BattleCoins,
		forSale = true
	},	
	Vengance = {
		imageID = "rbxassetid://14067235050",
		rarity = "Legendary",
		name = "Vengance",
		price = 200,
		currency = CurrenciesEnum.BattleCoins,
	},
	Gothic_Girl = {
		imageID = "rbxassetid://14067301987",
		rarity = "Epic",
		name = "Gothic",
		forSale = false,
	},
	Death = {
		imageID = "rbxassetid://14091156176",
		rarity = "Legendary",
		name = "Death",
		price = 200,
		currency = CurrenciesEnum.BattleCoins,
		forSale = false
	},
}
