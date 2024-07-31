local DataConfig = {}
local Prestiges = require(game.ReplicatedStorage.Source.Assets.Prestiges)
local WeaponsEnum = require(game.ReplicatedStorage.Source.Enums.WeaponsEnum)


DataConfig.weaponTemplate = {
	owned = true,
	customization = {},
	level = 0,
	modifications = {},
}

DataConfig.purchasableWeaponTemplate = {
	owned = false,
	customization = {},
	level = 0,
	modifications = {},
}

DataConfig.powerTemplate = {
	customization = {},
	level = 0,
	upgrades = {},
}

DataConfig.profileTemplate = {
	battleCoins = 0,
	battleGems = 0,	
	weapons = {
		[WeaponsEnum.WeaponNames.M4A4] = table.clone(DataConfig.weaponTemplate),
		[WeaponsEnum.WeaponNames.Pistol] = table.clone(DataConfig.weaponTemplate),
		[WeaponsEnum.WeaponNames.SPAS12] = table.clone(DataConfig.purchasableWeaponTemplate),
		[WeaponsEnum.WeaponNames.AA12] = table.clone(DataConfig.purchasableWeaponTemplate),
		[WeaponsEnum.WeaponNames.BarrettM82A1] = table.clone(DataConfig.purchasableWeaponTemplate),
		[WeaponsEnum.WeaponNames.BFG50] = table.clone(DataConfig.purchasableWeaponTemplate),
		[WeaponsEnum.WeaponNames.AUG3] = table.clone(DataConfig.purchasableWeaponTemplate),
		[WeaponsEnum.WeaponNames.AK47] = table.clone(DataConfig.purchasableWeaponTemplate),
		[WeaponsEnum.WeaponNames.DEagle] = table.clone(DataConfig.purchasableWeaponTemplate),
		[WeaponsEnum.WeaponNames.P90] = table.clone(DataConfig.purchasableWeaponTemplate),
		[WeaponsEnum.WeaponNames.Crossbow] = table.clone(DataConfig.purchasableWeaponTemplate),
		[WeaponsEnum.WeaponNames.KrissVector] = table.clone(DataConfig.purchasableWeaponTemplate),
		[WeaponsEnum.WeaponNames.Uzi] = table.clone(DataConfig.purchasableWeaponTemplate),
	},
	skins = {},
	colors = {},
	level = 0,
	prestige = 0,
	experience = 0,
	knockouts = 0,
	defeats = 0,
	lastLogin = os.time(),
	lastDailyReward = os.time(),
	destroyedObjects = 0,
	days = 0,
	codes = {},
	settings = {
		music = true,
	},
	devProducts = {},
	loadout = {
		weaponEquipped = WeaponsEnum.WeaponNames.M4A4,
		primary = WeaponsEnum.WeaponNames.M4A4,
		secondary = WeaponsEnum.WeaponNames.Pistol,
	},
	battlepass = {
		currentSeason = "season_1",
		season_1 = {
			level = 1,
			experience = 0,
			owned = false,
			claimedLevels = {
				freepass = {},
				battlepass = {},
			},
		},
		season_2 = {
			level = 1,
			experience = 0,
			owned = false,
			claimedLevels = {
				freepass = {},
				battlepass = {},
			},
		},
	},
	challenges = {
		weekly = {},
		daily = {},
	},
	crates = {},
	emotes = {
		emotesOwned = {},
		emotesEquipped = {},
	},
}


return DataConfig
