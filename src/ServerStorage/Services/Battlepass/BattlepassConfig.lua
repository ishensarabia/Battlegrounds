local ReplicatedStorage = game:GetService("ReplicatedStorage")
--Assets
local Skins = require(ReplicatedStorage.Source.Assets.Skins)
local BattlepassConfig = {}
--Reward types
BattlepassConfig.RewardTypes = {
	BattleCoins = "BattleCoins",
	BattleGems = "BattleGems",
	Experience_Boost = "Experience_Boost",
	Crate = "Crate",
	Skin = "Skin",
	Emote = "Emote",
}

--Reward descriptions
BattlepassConfig.RewardDescriptions = {
	[BattlepassConfig.RewardTypes.BattleCoins] = "BattleCoins are the main currency of the game. You can use them to buy crates and more!",
	[BattlepassConfig.RewardTypes.BattleGems] = "BattleGems are the premium currency of the game. You can use them to buy crates and more!",
	[BattlepassConfig.RewardTypes.Experience_Boost] = "Experience Boost is a boost that will give you 2x experience for 1 hour!",
	[BattlepassConfig.RewardTypes.Crate] = "Crate is a box that contains a random weapon, customization or boost!",
	[BattlepassConfig.RewardTypes.Skin] = "Skin is a cosmetic that changes the appearance of your weapon!",
	[BattlepassConfig.RewardTypes.Emote] = "Emote is a cosmetic that changes the appearance of your emote wheel!",
}

--Rarity of rewards
BattlepassConfig.Rarity = {
	Common = "Common",
	Rare = "Skins_Crate",
	Epic = "Epic",
	Legendary = "Legendary",
	Mythic = "Mythic",
}

--Images
BattlepassConfig.RewardIcons = {
	[BattlepassConfig.RewardTypes.BattleCoins] = "rbxassetid://13343092476",
	[BattlepassConfig.RewardTypes.BattleGems] = "rbxassetid://13357306942",
	[BattlepassConfig.RewardTypes.Experience_Boost] = "rbxassetid://13352370334",
	[BattlepassConfig.RewardTypes.Crate] = "rbxassetid://1532101515",
}

--Rarity to color of rewards dictionary
BattlepassConfig.RarityColors = {
	[BattlepassConfig.Rarity.Common] = Color3.fromRGB(39, 180, 126),
	[BattlepassConfig.Rarity.Rare] = Color3.fromRGB(0, 132, 255),
	[BattlepassConfig.Rarity.Epic] = Color3.fromRGB(223, 226, 37),
	[BattlepassConfig.Rarity.Legendary] = Color3.fromRGB(174, 56, 204),
	[BattlepassConfig.Rarity.Mythic] = Color3.fromRGB(184, 17, 17),
}

BattlepassConfig.seasonDevProdctsDictionary = {
	Season_1 = 1532101515,
}

BattlepassConfig.weaponTemplate = {
	Customization = {},

	Modifications = {},
}

--Battlepass rewards per season
BattlepassConfig.rewards = {
	Season_1 = {
		[1] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 150,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
			},
		},
		[2] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
			},
		},
		[3] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
			},
		},
		[4] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
			},
		},
		[5] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
			},
		},
		[6] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Melancoly,
					rarityColor = BattlepassConfig.RarityColors[Skins.Melancoly.rarity],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
			},
		},
		[7] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,

					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
			},
		},
		[8] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleCoins,
					rewardAmount = 1000,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 100,
					rarity = BattlepassConfig.Rarity.Common,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Common],
				},
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
				[4] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateName = "Skins_Crate",
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
			},
		},
		[9] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = BattlepassConfig.Rarity.Epic,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Epic],
				},
			},
		}
	},
}

return BattlepassConfig
