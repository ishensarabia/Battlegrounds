local DataConfig = {}
local Prestiges = require(game.ReplicatedStorage.Source.Assets.Prestiges)
local LoadoutEnum = require(game.ReplicatedStorage.Source.Enums.LoadoutEnum)


DataConfig.weaponTemplate = {
	owned = true,
	customization = {},
	level = 0,
	modifications = {},
}

DataConfig.gadgetTemplate = {
	owned = true,
	customization = {},
	level = 0,
	upgrades = {},
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
		[LoadoutEnum.WeaponNames.M16A1] = table.clone(DataConfig.weaponTemplate),
		[LoadoutEnum.WeaponNames.Pistol] = table.clone(DataConfig.weaponTemplate),
		[LoadoutEnum.WeaponNames.M4A4] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.SPAS12] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.AA12] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.BarrettM82A1] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.BFG50] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.AUG3] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.AK47] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.DEagle] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.Crossbow] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.KrissVector] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.Uzi] = table.clone(DataConfig.purchasableWeaponTemplate),
		[LoadoutEnum.WeaponNames.SVD] = table.clone(DataConfig.purchasableWeaponTemplate),
	},
	gadgets = {
		-- [LoadoutEnum.GadgetNames.Grenade] = table.clone(DataConfig.gadgetTemplate),
		[LoadoutEnum.GadgetNames.HandCannon] = table.clone(DataConfig.gadgetTemplate),
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
		weaponEquipped = LoadoutEnum.WeaponNames.M16A1,
		primary = LoadoutEnum.WeaponNames.M16A1,
		secondary = LoadoutEnum.WeaponNames.Pistol,
		gadget1 = LoadoutEnum.GadgetNames.HandCannon,
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
