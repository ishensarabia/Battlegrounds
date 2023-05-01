local DataConfig = {}
--External configs
DataConfig.BattlepassConfig = require(script.Parent.Parent.Battlepass.BattlepassConfig)

DataConfig.profileTemplate = {
	BattleCoins = 0,
	BattleGems = 0,
	Weapons = {
		Rocket_Launcher = {
			Owned = true,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {}
					
		},
		Crossbow = {
			Owned = false,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {}
		},
		Pistol = {
			Owned = true,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {}
		},
		["Rail-Rifle"] = {
			Owned = true,
			Rank = 0,
			Prestige = "Beginner",
			Customization = {}
		},
	},
	Rank = 0,
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
	Loadout = {},
	Battlepass = {
		currentSeason = "Season_1",
		Season_1 = {
			Level = 1,
			Experience = 0,
			Owned = false,
		},
	},
}

DataConfig.weaponTemplate = {
	Customization = {},

	Modifications = {},
}

DataConfig.powerTemplate = {
	Customization = {},

	Upgrades = {}
}

return DataConfig
