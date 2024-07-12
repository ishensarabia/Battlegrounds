local ReplicatedStorage = game:GetService("ReplicatedStorage")
--Assets
local Skins = require(ReplicatedStorage.Source.Assets.Skins)
local Emotes = require(ReplicatedStorage.Source.Assets.Emotes)
local EmoteIcons = require(ReplicatedStorage.Source.Assets.EmoteIcons)
--Enums
local RaritiesEnum = require(ReplicatedStorage.Source.Enums.RaritiesEnum)
local BattlepassConfig = {}

BattlepassConfig.SEASON_REFRESH_RATE = 60 * 60 * 24 * 45 -- 1 month and a half
BattlepassConfig.RESET_TIME_OFFSET = -60 * 60 * 4 -- Amount of time to offset from GMT
--Reward types
BattlepassConfig.RewardTypes = {
	BattleCoins = "BattleCoins",
	BattleGems = "BattleGems",
	Experience_Boost = "Experience_Boost",
	Crate = "Crate",
	Skin = "Skin",
	Emote = "Emote",
	Emote_Icon = "Emote_Icon",
	Knockout_Effect = "Knockout_Effect",
}

--Reward descriptions
BattlepassConfig.RewardDescriptions = {
	[BattlepassConfig.RewardTypes.BattleCoins] = "BattleCoins are the main currency of the game. You can use them to buy crates and more!",
	[BattlepassConfig.RewardTypes.BattleGems] = "BattleGems are the premium currency of the game. You can use them to buy crates and more!",
	[BattlepassConfig.RewardTypes.Experience_Boost] = "Experience Boost is a boost that will give you 2x experience for 1 hour!",
	[BattlepassConfig.RewardTypes.Crate] = "Crate is a box that contains a random weapon, customization or boost!",
	[BattlepassConfig.RewardTypes.Skin] = "Skin is a cosmetic that changes the appearance of your weapon!",
	[BattlepassConfig.RewardTypes.Emote] = "An Emote is a signature move your player can do in your emote wheel!",
	[BattlepassConfig.RewardTypes.Emote_Icon] = "an Emote Icon is a cosmetic that can be displayed alongside normal emotes or individually in your emote wheel!",
}

--Images
BattlepassConfig.RewardIcons = {
	[BattlepassConfig.RewardTypes.BattleCoins] = "rbxassetid://13343092476",
	[BattlepassConfig.RewardTypes.BattleGems] = "rbxassetid://13357306942",
	[BattlepassConfig.RewardTypes.Experience_Boost] = "rbxassetid://13352370334",
	[BattlepassConfig.RewardTypes.Crate] = "rbxassetid://1532101515",
}

BattlepassConfig.seasonDevProdctsDictionary = {
	Season_1 = 1532101515,
}

--Battlepass rewards per season
BattlepassConfig.rewards = {
	Season_1 = {
		[1] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 150,
					rarity = RaritiesEnum.Common,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.SpiderSpirit,
					rarityColor = RaritiesEnum.Colors[Skins.SpiderSpirit.rarity],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Emote_Icon,
					rarityColor = RaritiesEnum.Colors[EmoteIcons.Im_Fine_Skull.rarity],
					rewardEmoteIcon = EmoteIcons.Im_Fine_Skull,
				},
			},
		},
		[2] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Emote,
					rewardEmote = Emotes.Ballin,
					rarityColor = RaritiesEnum.Colors[Emotes.Ballin.rarity],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,
					rarity = RaritiesEnum.Common,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
			},
		},
		[3] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,
					rarity = RaritiesEnum.Common,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote,
					rewardEmote = Emotes.Take_The_L,
					rarityColor = RaritiesEnum.Colors[Emotes.Take_The_L.rarity],
				},
			},
		},
		[4] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,
					rarity = RaritiesEnum.Common,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote_Icon,
					rarityColor = RaritiesEnum.Colors[EmoteIcons.Ghost.rarity],
					rewardEmoteIcon = EmoteIcons.Ghost,
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
			},
		},
		[5] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = RaritiesEnum.Common,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
			},
		},
		[6] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Melancoly,
					rarityColor = RaritiesEnum.Colors[Skins.Melancoly.rarity],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
			},
		},
		[7] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,

					rarity = RaritiesEnum.Common,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = RaritiesEnum.Common,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
			},
		},
		[8] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,
					rarity = RaritiesEnum.Common,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = RaritiesEnum.Common,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
				[4] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
			},
		},
		[9] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote_Icon,
					rarity = EmoteIcons.Death.rarity,
					rewardEmoteIcon = EmoteIcons.Death,
				},
			},
		},
		[10] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote,
					rewardEmote = Emotes.The_Robot,
					rarityColor = RaritiesEnum.Colors[Emotes.The_Robot.rarity],
				},
			},
		},
		[11] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Tech,
					rarityColor = RaritiesEnum.Colors[Skins.Tech.rarity],
				},
			},
			battlepass = {},
		},
		[12] = {
			freepass = {},
			battlepass = {},
		},
		[13] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = RaritiesEnum.Common,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
			},
			battlepass = {},
		},
		[14] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
			},
			battlepass = {},
		},
		[15] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.SkullRoses,
					rarityColor = RaritiesEnum.Colors[Skins.SkullRoses.rarity],
				},
			},
		},
		[16] = {
			freepass = {},
			battlepass = {},
		},
		[17] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote,
					rewardEmote = Emotes.Did_it,
					rarityColor = RaritiesEnum.Colors[Emotes.Did_it.rarity],
				},
			},
		},
		[18] = {
			freepass = {},
			battlepass = {},
		},
		[19] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.SpiderSense,
					rarityColor = RaritiesEnum.Colors[Skins.SpiderSense.rarity],
				},
			},
		},
		[20] = {
			freepass = {},
			battlepass = {},
		},
		[21] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote,
					rewardEmote = Emotes.Rider,
					rarityColor = RaritiesEnum.Colors[Emotes.Rider.rarity],
				},
			},
		},
		[22] = {
			freepass = {},
			battlepass = {},
		},
		[23] = {
			freepass = {},
			battlepass = {},
		},
		[24] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote,
					rewardEmote = Emotes.Slitherin,
					rarityColor = RaritiesEnum.Colors[Emotes.Slitherin.rarity],
				},
			},
		},
		[25] = {
			freepass = {},
			battlepass = {},
		},
		[26] = {
			freepass = {},
			battlepass = {},
		},
		[27] = {
			freepass = {},
			battlepass = {},
		},
		[28] = {
			freepass = {},
			battlepass = {},
		},
		[29] = {
			freepass = {},
			battlepass = {},
		},
		[30] = {
			freepass = {},
			battlepass = {},
		},
		[31] = {
			freepass = {},
			battlepass = {},
		},
		[32] = {
			freepass = {},
			battlepass = {},
		},
		[33] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.MayanFigures,
					rarityColor = RaritiesEnum.Colors[Skins.MayanFigures.rarity],
				},
			},
		},
		[34] = {
			freepass = {},
			battlepass = {},
		},
		[35] = {
			freepass = {},
			battlepass = {},
		},
		[36] = {
			freepass = {},
			battlepass = {},
		},
		[37] = {
			freepass = {},
			battlepass = {},
		},
		[38] = {
			freepass = {},
			battlepass = {},
		},
		[39] = {
			freepass = {},
			battlepass = {},
		},
		[40] = {
			freepass = {},
			battlepass = {},
		},
		[41] = {
			freepass = {},
			battlepass = {},
		},
		[42] = {
			freepass = {},
			battlepass = {},
		},
		[43] = {
			freepass = {},
			battlepass = {},
		},
		[44] = {
			freepass = {},
			battlepass = {},
		},
		[45] = {
			freepass = {},
			battlepass = {},
		},
		[46] = {
			freepass = {},
			battlepass = {},
		},
		[47] = {
			freepass = {},
			battlepass = {},
		},
		[48] = {
			freepass = {},
			battlepass = {},
		},
		[49] = {
			freepass = {},
			battlepass = {},
		},
		[50] = {
			freepass = {},
			battlepass = {},
		},
	},
}

BattlepassConfig.Seasons = {
	Season_1 = {
		seasonName = "Season 1",
		seasonNumber = 1,
		seasonImage = "rbxassetid://13343092476",
		seasonDescription = "The first season of the game!",
	},
}

return BattlepassConfig
