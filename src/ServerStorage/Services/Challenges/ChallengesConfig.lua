local ChallengesConfig = {}

ChallengesConfig.ChallengesTypes = {
	Daily = "Daily",
	Weekly = "Weekly",
}

ChallengesConfig.MaxChallengesPerType = {
	Daily = 4,
	Weekly = 3,
}

ChallengesConfig.RewardTypeIcons = {
	BattleCoins = "rbxassetid://10835882861",
	BattleGems = "rbxassetid://10835980573",
	BattlepassExp = "rbxassetid://13474525765",
}

ChallengesConfig.challenges = {
	Daily = {
		{
			name = "First knockout!",
			description = "Get the first knockout of the game",
			typeOfProgression = "Knockouts",
			goal = 1,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 100,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 10,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 100,
				},
			},
		},
        {
			name = "Make those coins rain!",
			description = "Earn 250 coins",
			typeOfProgression = "EarnCoins",
			goal = 250,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 100,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 10,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 100,
				},
			},
		},
		{
			name = "Make those gems rain!",
			description = "Earn 25 gems",
			typeOfProgression = "EarnGems",
			goal = 25,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 100,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 10,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 100,
				},
			},
		},
		{
			name = "Blow it up!",
			description = "Destroy 10 objects",
			typeOfProgression = "DestroyObjects",
			goal = 10,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 100,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 10,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 100,
				},
			},
		},
		{
			name = "Heads will roll!",
			description = "Get 10 headshot knockouts",
			typeOfProgression = "HeadshotKnockouts",
			goal = 10,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 100,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 10,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 100,
				},
			},
		},
		{
			name = "Rebuilding the world!",
			description = "Build 5 objects",
			typeOfProgression = "BuildObjects",
			goal = 5,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 100,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 10,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 100,
				},
			},
		},
		{
			name = "Rebuilding the world!",
			description = "Build 5 objects",
			typeOfProgression = "BuildObjects",
			goal = 5,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 100,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 10,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 100,
				},
			},
		},
		{
			name = "Close combat!",
			description = "Get 10 melee knockouts",
			typeOfProgression = "MeleeKnockouts",
			goal = 10,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 100,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 10,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 100,
				},
			},
		},
		{
			name = "Blow them up!",
			description = "Get 3 explosive knockouts",
			typeOfProgression = "ExplosiveKnockouts",
			goal = 3,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 100,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 10,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 100,
				},
			},
		},
		{
			name = "Top of the list!",
			description = "Reach the top 10 of the leaderboard 3 times",
			typeOfProgression = "Top10Leaderboard",
			goal = 3,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 400,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 30,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 330,
				},
			},
		},
		{
			name = "Sniper frenzy!",
			description = "Get 5 sniper knockouts",
			typeOfProgression = "SniperKnockouts",
			goal = 5,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 100,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 20,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 300,
				},
			},
		}

       
	},
	Weekly = {
		{
			name = "Look at those badges!",
			description = "Earn 5 multiknockout badges (double knockout, triple knockout, etc.)",
			goal = 5,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 1000,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 100,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 1000,
				},
			},
		},
		{
			name = "The grand architect!",
			description = "Build 100 objects",
			typeOfProgression = "BuildObjects",
			goal = 100,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 1000,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 100,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 1000,
				},
			},
		},
		{
			name = "The head collector!",
			description = "Get 33 headshot knockouts",
			typeOfProgression = "HeadshotKnockouts",
			goal = 33,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 1000,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 100,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 1000,
				},
			},
		},
		{
			name = "Environmental Havoc!",
			description = "Destroy 100 objects",
			typeOfProgression = "DestroyObjects",
			goal = 100,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 1000,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 100,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 1000,
				},
			},
		},
		{
			name = "Master badge collector!",
			description = "Earn 10 multiknockout badges (double knockout, triple knockout, etc.)",
			typeOfProgression = "MultiKnockoutBadges",
			goal = 10,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 1000,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 100,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 1000,
				},
			},
		},
		{
			name = "Sniper Elite!",
			description = "Get 35 sniper knockouts",
			typeOfProgression = "SniperKnockouts",
			goal = 35,
			rewards = {
				{
					rewardType = "BattleCoins",
					rewardAmount = 1000,
				},
				{
					rewardType = "BattleGems",
					rewardAmount = 100,
				},
				{
					rewardType = "BattlepassExp",
					rewardAmount = 1000,
				},
			},
		}
	},
}

return ChallengesConfig
