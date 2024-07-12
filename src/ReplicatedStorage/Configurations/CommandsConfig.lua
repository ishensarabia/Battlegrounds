return {
	accessLevels = {
		["Owner"] = {
			userIDs = { 1398838756 },
			groupIDs = { 1 },
		},
	},

	commands = {
		["AddExperience"] = {
			accessLevel = "Owner",
			alias = "/addExperience",
			secondaryAlias = "/addExp",
			arguments = {
				{ name = "player", type = "Player" },
				{ name = "amount", type = "number" },
			},
		},
		["WipeData"] = {
			accessLevel = "Owner",
			alias = "/wipeData",
			secondaryAlias = "/wipe",
			arguments = {
				{ name = "player", type = "Player" },
			},
		},
		["ApplyDamage"] = {
			accessLevel = "Owner",
			alias = "/applyDamage",
			secondaryAlias = "/damage",
		}
	},
}
