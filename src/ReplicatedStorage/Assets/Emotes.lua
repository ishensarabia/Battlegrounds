local ReplicatedStorage = game:GetService("ReplicatedStorage")
local raritiesEnum = require(ReplicatedStorage.Source.Enums.RaritiesEnum)
local emotes = {
	Club_Dance = {
		name = "Club Dance",
		animation = "rbxassetid://13937073595",
		defaultTempo = 1,
		rarity = raritiesEnum.Rare,
	},
	Sleep = {
		name = "Sleep",
		animation = "rbxassetid://5375125612",
		defaultTempo = 1,
		rarity = raritiesEnum.Common,
	},
	Boneless = {
		name = "Boneless",
		animation = "rbxassetid://14001884975",
		defaultTempo = 1,
		rarity = raritiesEnum.Legendary,
	},
	Feet_Clap = {
		name = "Feet Clap",
		animation = "rbxassetid://14023662289",
		defaultTempo = 1,
		rarity = raritiesEnum.Epic,
	},
	Dab = {
		name = "Dab",
		animation = "rbxassetid://14023813953",
		defaultTempo = 1,
		rarity = raritiesEnum.Common,
	},
	Cosita = {
		name = "Cosita",
		animation = "rbxassetid://14023896850",
		defaultTempo = 1,
		rarity = raritiesEnum.Mythic,
	},
	The_Twist = {
		name = "The Twist",
		animation = "rbxassetid://14026838589",
		defaultTempo = 1,
		rarity = raritiesEnum.Legendary,
	},
	Zombiller = {
		name = "Zombiller",
		animation = "rbxassetid://14026892525",
		defaultTempo = 1,
		rarity = raritiesEnum.Mythic,
	},
	Worming = {
		name = "Worming",
		animation = "rbxassetid://14027219860",
		defaultTempo = 1,
		rarity = raritiesEnum.Epic,
	},
	Hype = {
		name = "Hype",
		animation = "rbxassetid://14032019287",
		image = "rbxassetid://6403436054",
		defaultTempo = 1,
		rarity = raritiesEnum.Epic,
	},
	Fresh = {
		name = "Fresh",
		animation = "rbxassetid://14034445225",
		image = "rbxassetid://6403436054",
		defaultTempo = 1,
		rarity = raritiesEnum.Legendary,
	},
	Take_The_L = {
		name = "Take The L",
		animation = "rbxassetid://14044815170",
		defaultTempo = 1,
		rarity = raritiesEnum.Legendary,
	},
	The_Robot = {
		name = "The Robot",
		animation = "rbxassetid://14834257724",
		defaultTempo = 1,
		rarity = raritiesEnum.Epic,
	},
	Did_it = {
		name = "Did it" ,
		animation = "rbxassetid://15037294572",
		defaultTempo = 1,
		rarity = raritiesEnum.Mythic
	},
	Rider = {
		name = "Rider",
		animation = "rbxassetid://15038512335",
		defaultTempo = 1,
		rarity = raritiesEnum.Rare
	},
	Slitherin = {
		name = "Slitherin",
		animation = "rbxassetid://15096873233",
		defaultTempo = 1,
		rarity = raritiesEnum.Epic
	},
	Ballin = {
		name = "Ballin",
		animation = "rbxassetid://15105435828",
		defaultTempo = 1,
		rarity = raritiesEnum.Rare
	}
}

return emotes
