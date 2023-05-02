local BattlepassConfig = {}

BattlepassConfig.RewardTypes = {
	BattleCoins = "BattleCoins",
	BattleGems = "BattleGems",
	Experience_Boost = "Experience_Boost",
	Crate = "Crate",
}

--Rarity of rewards
BattlepassConfig.Rarity = {
	Common = "Common",
	Rare = "Rare",
	Epic = "Epic",
	Legendary = "Legendary",
}

--Rarity to color of rewards dictionary
BattlepassConfig.RarityColors = {
	[BattlepassConfig.Rarity.Common] = Color3.fromRGB(52, 130, 247),
	[BattlepassConfig.Rarity.Rare] = Color3.fromRGB(0, 255, 0),
	[BattlepassConfig.Rarity.Epic] = Color3.fromRGB(255, 208, 0),
	[BattlepassConfig.Rarity.Legendary] = Color3.fromRGB(255, 0, 0),
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
					rewardAmount = 600,
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
					Rarity = BattlepassConfig.Rarity.Rare,
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
					crateRarity = "Rare",
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
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateRarity = "Rare",
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
					crateRarity = "Rare",
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
					rewardType = BattlepassConfig.RewardTypes.Experience_Boost,
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Crate,
					crateRarity = "Rare",
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
			},
		},
		[6] = {
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
					crateRarity = "Rare",
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
					crateRarity = "Rare",
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
					crateRarity = "Rare",
					rarity = BattlepassConfig.Rarity.Rare,
					rarityColor = BattlepassConfig.RarityColors[BattlepassConfig.Rarity.Rare],
				},
			},
		},
	},
}

return BattlepassConfig
