local DataConfig = {}
--External configs
DataConfig.BattlepassConfig = require(script.Parent.Parent.Battlepass.BattlepassConfig)
DataConfig.profileTemplate = {
	BattleCoins = 0,
	BattleGems = 0,
	Weapons = {
		Rocket_Launcher = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		Crossbow = {
			Owned = true,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		Pistol = {
			Owned = true,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		M4A4 = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		Kriss_Vector = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		["SPAS-12"] = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		["AA-12"] = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		["Barrett-M82A1"] = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		["BFG-50"] = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		["AUG-3"] = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		["AK-47"] = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		["D-Eagle"] = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		["SCAR-L"] = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
		MK14 = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},

		["Rail-Rifle"] = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {},
		},
	},
	Skins = {},
	Colors = {},
	Level = 0,
	Experience = 0,
	Abilities = {},
	Knockouts = 0,
	Defeats = 0,
	LastLogin = os.time(),
	DestroyedObjects = 0,
	Days = 0,
	Codes = {},
	Settings = {
		["Music"] = true,
	},
	DevProducts = {},
	Loadout = {
		WeanEquipped = "Pistol",
	},
	Battlepass = {
		currentSeason = "Season_1",
		Season_1 = {
			Level = 1,
			Experience = 0,
			Owned = false,
			ClaimedLevels = {
				Freepass = {},
				Battlepass = {},
			},
			Season_2 = {
				Level = 1,
				Experience = 0,
				Owned = false,
				ClaimedLevels = {
					Freepass = {},
					Battlepass = {},
				},
			},
		},
	},
	Challenges = {
		Weekly = {},
		Daily = {},
	},
	Crates = {},
	Emotes = {
		EmotesOwned = {},
		EmotesEquipped = {},
	},
}

DataConfig.weaponTemplate = {
	Customization = {},

	Modifications = {},
}

DataConfig.powerTemplate = {
	Customization = {},

	Upgrades = {},
}

return DataConfig
