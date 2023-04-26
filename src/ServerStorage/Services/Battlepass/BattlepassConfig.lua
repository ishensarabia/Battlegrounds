local BattlepassConfig = {}

BattlepassConfig.rewardTypes = {
	BattleCoins = "BattleCoins",
	BattleGems = "BattleGems",
	Experience_Boost = "Experience_Boost",
	Crate = "Crate",
}

BattlepassConfig.weaponTemplate = {
	Customization = {},

	Modifications = {},
}

--Battlepass rewards per season
BattlepassConfig.rewards = {
	Season1 = {
		[1] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.rewardTypes.BattleCoins,
					rewardAmount = 600,
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.rewardTypes.BattleCoins,
					rewardAmount = 1000,
				},
				[2] = {
					rewardType = BattlepassConfig.rewardTypes.BattleGems,
					rewardAmount = 100,
				},
				[3] = {
					rewardType = BattlepassConfig.rewardTypes.Experience_Boost,
				},
			},
		},
		[2] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.rewardTypes.BattleGems,
					rewardAmount = 100,
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.rewardTypes.BattleCoins,
					rewardAmount = 1000,
				},
				[2] = {
					rewardType = BattlepassConfig.rewardTypes.Experience_Boost,
				},
				[3] = {
					rewardType = BattlepassConfig.rewardTypes.Crate,
					crateRarity = "Rare",
				},
			},
		},
	},
}

return BattlepassConfig
