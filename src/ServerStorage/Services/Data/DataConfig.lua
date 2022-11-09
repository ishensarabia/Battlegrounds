local DataConfig = {}

DataConfig.profileTemplate = {
	BattleCoins = 0,
	BattleGems = 0,
	Weapons = {
		Rocket_Launcher = true,
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
