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
		["AddBattlepassExperience"] = {
			accessLevel = "Owner",
			alias = "/addBattlepassExperience",
			secondaryAlias = "/addBpExp",
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
		},
		["AddSkin"] = {
			accessLevel = "Owner",
			alias = "/addSkin",
			secondaryAlias = "/skin",
		},
		["UpdateChallengeProgresion"] = {
			accessLevel = "Owner",
			alias = "/updateChallengeProgression",
			secondaryAlias = "/updateChallenge",
		},
		["AddCurrency"] ={
			accessLevel = "Owner",
			alias = "/addCurrency",
			secondaryAlias = "/currency",
		},
	},
}
