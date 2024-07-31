local ReplicatedStorage = game:GetService("ReplicatedStorage")
--Assets
local Skins = require(ReplicatedStorage.Source.Assets.Skins)
local Emotes = require(ReplicatedStorage.Source.Assets.Emotes)
local EmoteIcons = require(ReplicatedStorage.Source.Assets.EmoteIcons)
local WeaponsEnum = require(ReplicatedStorage.Source.Enums.WeaponsEnum)
local Weapons = ReplicatedStorage.Weapons
--Enums
local RaritiesEnum = require(ReplicatedStorage.Source.Enums.RaritiesEnum)
local BattlepassConfig = {}

BattlepassConfig.SEASON_REFRESH_RATE = 60 * 60 * 24 * 45 -- 1 month and a half
BattlepassConfig.RESET_TIME_OFFSET = -60 * 60 * 4 -- Amount of time to offset from GMT
--Reward types
BattlepassConfig.RewardTypes = {
	BattleCoins = "battleCoins",
	BattleGems = "battleGems",
	Experience_Boost = "Experience_Boost",
	Crate = "Crate",
	Skin = "Skin",
	Emote = "Emote",
	Emote_Icon = "Emote_Icon",
	Knockout_Effect = "Knockout_Effect",
	Weapon = "Weapon",
}

--Reward descriptions
BattlepassConfig.RewardDescriptions = {
	[BattlepassConfig.RewardTypes.BattleCoins] = "BattleCoins are the main currency of the game. You can use them to buy crates and more!",
	[BattlepassConfig.RewardTypes.BattleGems] = "BattleGems are the premium currency of the game. You can use them to buy crates and more!",
	[BattlepassConfig.RewardTypes.Experience_Boost] = "Experience Boost is a boost that will give you 2x experience for 1 hour!",
	[BattlepassConfig.RewardTypes.Crate] = "Crate is a box that contains a random weapon, customization or boost!",
	[BattlepassConfig.RewardTypes.Skin] = "Skin is a cosmetic that changes the appearance of your weapon!",
	[BattlepassConfig.RewardTypes.Emote] = "An Emote is a signature move your player can do in your emote wheel!",
	[BattlepassConfig.RewardTypes.Emote_Icon] = "An Emote Icon is a cosmetic that can be displayed alongside normal emotes or individually in your emote wheel!",
	[BattlepassConfig.RewardTypes.Weapon] = "A weapon is a tool that can be used to wipe out your enemies!",
}

--Images
BattlepassConfig.RewardIcons = {
	[BattlepassConfig.RewardTypes.BattleCoins] = "rbxassetid://13343092476",
	[BattlepassConfig.RewardTypes.BattleGems] = "rbxassetid://13357306942",
	[BattlepassConfig.RewardTypes.Experience_Boost] = "rbxassetid://13352370334",
	[BattlepassConfig.RewardTypes.Crate] = "rbxassetid://1532101515",
}

BattlepassConfig.seasonDevProdctsDictionary = {
	season_1 = 1892016491,
}

--Battlepass rewards per season
BattlepassConfig.rewards = {
	season_1 = {
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
				[3] = {
					rewardType = BattlepassConfig.RewardTypes.Weapon,
					weaponName = WeaponsEnum.WeaponNames.P90,
					rarityColor = RaritiesEnum.Colors[Weapons[WeaponsEnum.WeaponNames.P90]:GetAttribute("Rrarity")],
				}
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
				[2] = {
					rewardType = BattlepassConfig.RewardTypes.Weapon,
					weaponName = WeaponsEnum.WeaponNames.Rhino,
					rarityColor = RaritiesEnum.Colors[Weapons[WeaponsEnum.WeaponNames.Rhino]:GetAttribute("Rrarity")],
				}
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
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 1000,
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
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
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote_Icon,
					rewardEmoteIcon = EmoteIcons.Savage_Claws,
					rarityColor = RaritiesEnum.Colors[EmoteIcons.Savage_Claws.rarity],
				},
			},
		},
		[12] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 2_500,
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Fallout,
					rarityColor = RaritiesEnum.Colors[Skins.Fallout.rarity],
				},
			},
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
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote_Icon,
					rewardEmoteIcon = EmoteIcons.Heart_Sign,
					rarityColor = RaritiesEnum.Colors[EmoteIcons.Heart_Sign.rarity],
				},
			},
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
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Magma,
					rarityColor = RaritiesEnum.Colors[Skins.Magma.rarity],
				},
			},
		},
		[17] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rewardAmount = 2_500,
					rarity = RaritiesEnum.Rare,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Rare],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote,
					rewardEmote = Emotes.Did_it,
					rarityColor = RaritiesEnum.Colors[Emotes.Did_it.rarity],
				},
			},
		},
		[18] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Monster,
					rarityColor = RaritiesEnum.Colors[Skins.Monster.rarity],
				},
			},
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
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rarity = RaritiesEnum.Common,
					rewardAmount = 1_000,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Common],
				},
			},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote_Icon,
					rewardEmoteIcon = EmoteIcons.Wondering_Star,
					rarityColor = RaritiesEnum.Colors[EmoteIcons.Wondering_Star.rarity],
				},
			},
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
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Alien,
					rarityColor = RaritiesEnum.Colors[Skins.Alien.rarity],
				},
			},
			battlepass = {},
		},
		[23] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.TidalWaves,
					rarityColor = RaritiesEnum.Colors[Skins.TidalWaves.rarity],
				},
			},
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
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote_Icon,
					rewardEmoteIcon = EmoteIcons.Detective,
					rarityColor = RaritiesEnum.Colors[EmoteIcons.Detective.rarity],
				},
			},
		},
		[26] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rarity = Skins.Firy.rarity,
					rewardSkin = Skins.Firy,
				},
			},
		},
		[27] = {
			freepass = {},
			battlepass = {},
		},
		[28] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Electric,
					rarityColor = RaritiesEnum.Colors[Skins.Electric.rarity],
				},
			},
		},
		[29] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Storm,
					rarityColor = RaritiesEnum.Colors[Skins.Storm.rarity],
				},
			},
		},
		[30] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote_Icon,
					rewardEmoteIcon = EmoteIcons.Alien,
					rarityColor = RaritiesEnum.Colors[EmoteIcons.Alien.rarity],
				},
			},
			battlepass = {},
		},
		[31] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote,
					rewardEmote = Emotes.T_Pose,
					rarityColor = RaritiesEnum.Colors[Emotes.T_Pose.rarity],
				},
			},
		},
		[32] = {
			freepass = {},
			battlepass = {

			},
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
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Spiderweb,
					rarityColor = RaritiesEnum.Colors[Skins.Spiderweb.rarity],
				},
			},
			battlepass = {},
		},
		[35] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Cards,
					rarityColor = RaritiesEnum.Colors[Skins.Cards.rarity],
				},
			},
		},
		[36] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rarity = RaritiesEnum.Epic,
					rewardAmount = 2_500,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Epic],
				}
			},
			battlepass = {},
		},
		[37] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Fierce,
					rarityColor = RaritiesEnum.Colors[Skins.Fierce.rarity],
				},
			},
		},
		[38] = {
			freepass = {},
			battlepass = {},
		},
		[39] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote_Icon,
					rewardEmoteIcon = EmoteIcons.Flame,
					rarityColor = RaritiesEnum.Colors[EmoteIcons.Flame.rarity],
				},
			},
		},
		[40] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Tiger,
					rarityColor = RaritiesEnum.Colors[Skins.Tiger.rarity],
				},
			},
		},
		[41] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.MarbleGold,
					rarityColor = RaritiesEnum.Colors[Skins.MarbleGold.rarity],
				},
			},
		},
		[42] = {
			freepass = {},
			battlepass = {},
		},
		[43] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Slime,
					rarityColor = RaritiesEnum.Colors[Skins.Slime.rarity],
				},
			},
		},
		[44] = {
			freepass = {},
			battlepass = {},
		},
		[45] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Enigma,
					rarityColor = RaritiesEnum.Colors[Skins.Enigma.rarity],
				},
			},
		},
		[46] = {
			freepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Emote_Icon,
					rewardEmoteIcon = EmoteIcons.Pirate_Flag,
					rarityColor = RaritiesEnum.Colors[EmoteIcons.Pirate_Flag.rarity],
				}
			},
			battlepass = {},
		},
		[47] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Blueprint,
					rarityColor = RaritiesEnum.Colors[Skins.Blueprint.rarity],
				},
			},
		},
		[48] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Cubism,
					rarityColor = RaritiesEnum.Colors[Skins.Cubism.rarity],
				},
			},
		},
		[49] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.BattleGems,
					rarity = RaritiesEnum.Legendary,
					rewardAmount = 3_500,
					rarityColor = RaritiesEnum.Colors[RaritiesEnum.Legendary],
				}
			},
		},
		[50] = {
			freepass = {},
			battlepass = {
				[1] = {
					rewardType = BattlepassConfig.RewardTypes.Skin,
					rewardSkin = Skins.Vampire,
					rarityColor = RaritiesEnum.Colors[Skins.Vampire.rarity],
				},
			},
		},
	},
}

BattlepassConfig.seasons = {
	season_1 = {
		seasonName = "Season 1",
		seasonNumber = 1,
		seasonImage = "rbxassetid://13343092476",
		seasonDescription = "The first season of the game!",
		maxLevel = 50,
	},
}

return BattlepassConfig
