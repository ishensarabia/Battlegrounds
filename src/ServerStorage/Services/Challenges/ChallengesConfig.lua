local ChallengesConfig = {}
local CurrenciesEnum = require(game.ReplicatedStorage.Source.Enums.CurrenciesEnum)
local RewardsEnum = require(game.ReplicatedStorage.Source.Enums.RewardsEnum)

ChallengesConfig.challengesTypes = {
	daily = "daily",
	weekly = "weekly",
}

ChallengesConfig.maxChallengesPerType = {
    daily = 4,
    weekly = 3,
}


ChallengesConfig.challenges = {
	daily = {
		{
			name = "First knockout!",
			description = "Get the first knockout of the game",
			typeOfProgression = "Knockouts",
			goal = 1,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 10,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 160,
				}
			},
		},
        {
			name = "Make those coins rain!",
			description = "Earn 250 BattleCoins",
			typeOfProgression = RewardsEnum.RewardTypes.BattleCoins,
			goal = 250,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 10,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 160,
				}
			},
		},
		{
			name = "Make those gems rain!",
			description = "Earn 25 gems",
			typeOfProgression = "EarnGems",
			goal = 25,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 10,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 160,
				}
			},
		},
		{
			name = "Blow it up!",
			description = "Destroy 10 objects",
			typeOfProgression = "DestroyObjects",
			goal = 10,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 10,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 3360,
				}
			},
		},
		{
			name = "Heads will roll!",
			description = "Get 10 headshot knockouts",
			typeOfProgression = "HeadshotKnockouts",
			goal = 10,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 10,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 260,
				}
			},
		},
		{
			name = "Rebuilding the world!",
			description = "Build 5 objects",
			typeOfProgression = "BuildObjects",
			goal = 5,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 10,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 16666,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 333,
				}
			},
		},
		{
			name = "Close combat!",
			description = "Get 10 melee knockouts",
			typeOfProgression = "MeleeKnockouts",
			goal = 10,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 10,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 260,
				}
			},
		},
		{
			name = "Blow them up!",
			description = "Get 3 explosive knockouts",
			typeOfProgression = "ExplosiveKnockouts",
			goal = 3,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 10,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 260,
				}
			},
		},
		{
			name = "Top of the list!",
			description = "Reach the top 5 of the leaderboard 3 times",
			typeOfProgression = "TopPlayers",
			goal = 3,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 400,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 30,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 330,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 260,
				}

			},
		},
		{
			name = "Sniper frenzy!",
			description = "Get 5 sniper knockouts",
			typeOfProgression = "SniperKnockouts",
			goal = 5,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 20,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 300,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 260,
				}
			},
		}

       
	},
	weekly = {
		{
			name = "Look at those badges!",
			description = "Earn 5 multiknockout badges (double knockout, triple knockout, etc.)",
			goal = 5,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 1000,
				}
			},
		},
		{
			name = "The grand architect!",
			description = "Build 100 objects",
			typeOfProgression = "BuildObjects",
			goal = 100,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 6666,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 1000,
				}
			},
		},
		{
			name = "The head collector!",
			description = "Get 33 headshot knockouts",
			typeOfProgression = "HeadshotKnockouts",
			goal = 33,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 1000,
				}
			},
		},
		{
			name = "Environmental Havoc!",
			description = "Destroy 100 objects",
			typeOfProgression = "DestroyObjects",
			goal = 100,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 1000,
				}
			},
		},
		{
			name = "Master badge collector!",
			description = "Earn 10 multiknockout badges (double knockout, triple knockout, etc.)",
			typeOfProgression = "MultiKnockoutBadges",
			goal = 10,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 1000,
				}
			},
		},
		{
			name = "Sniper Elite!",
			description = "Get 35 sniper knockouts",
			typeOfProgression = "SniperKnockouts",
			goal = 35,
			rewards = {
				{
					rewardType = RewardsEnum.RewardTypes.BattleCoins,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattleGems,
					rewardAmount = 100,
				},
				{
					rewardType = RewardsEnum.RewardTypes.BattlepassExp,
					rewardAmount = 1000,
				},
				{
					rewardType = RewardsEnum.RewardTypes.Experience,
					rewardAmount = 1000,
				}
			},
		}
	},
}

return ChallengesConfig
