local DataConfig = {}

DataConfig.profileTemplate = {
	BattleCoins = 0,
	BattleGems = 0,
	Weapons = {
		Rocket_Launcher = true,
	},
	Powers = {},
	Knockouts = 0,
	Defeats = 0,
	LastLogin = os.time(),
	ObjectsDestroyed = 0,
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
