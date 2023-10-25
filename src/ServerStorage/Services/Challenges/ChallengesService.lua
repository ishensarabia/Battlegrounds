local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ChallengesConfig = require(script.Parent.ChallengesConfig)

local ChallengesService = Knit.CreateService({
	Name = "ChallengesService",
	Client = {
		ChallengesInitialized = Knit.CreateSignal(),
		ChallengeReplaced = Knit.CreateSignal(),
		ChallengeProgressionUpdated = Knit.CreateSignal(),
		ChallengeCompleted = Knit.CreateSignal(),
		ChallengeClaimed = Knit.CreateSignal(),
	},
})

function ChallengesService:KnitStart()
	--services
	self._dataService = Knit.GetService("DataService")
	self._currencyService = Knit.GetService("CurrencyService")
	self._battlepassService = Knit.GetService("BattlepassService")

	Players.PlayerAdded:Connect(function(player)
		self:InitializePlayer(player)
	end)
end

function ChallengesService:GenerateChallenges(player, typeOfChallenge: string, challengesData: table)
	while #challengesData < ChallengesConfig.MaxChallengesPerType[typeOfChallenge] do
		local randomChallengeSelected =
			ChallengesConfig.challenges[typeOfChallenge][math.random(1, #ChallengesConfig.challenges[typeOfChallenge])]
		--Make sure the challenge isn't already in the challengesData
		if not table.find(challengesData, randomChallengeSelected) then
			table.insert(challengesData, randomChallengeSelected)
		end
	end
	return challengesData
end

function ChallengesService:InitializePlayer(player)
	--Check for active challenges
	local challengesData = self._dataService:GetKeyValue(player, "Challenges")
	local dailyStringToFormat = "Daily challenges generated at: %x, which is a %A, and the time is %X."
	local weeklyStringToFormat = "Weekly challenges generated at: %x, which is a %A, and the time is %X."

	local dailyChallengesGeneratedAt = os.date(dailyStringToFormat, challengesData.DailyGeneratedAt)
	local weeklyChallengesGeneratedAt = os.date(weeklyStringToFormat, challengesData.WeeklyGeneratedAt)

	warn(weeklyChallengesGeneratedAt)
	warn(dailyChallengesGeneratedAt)
	--If there's no weekly or daily challenges, generate them
	if
		(#challengesData.Weekly == 0 and not challengesData.WeeklyGeneratedAt)
		or (
			#challengesData.Weekly < ChallengesConfig.MaxChallengesPerType.Weekly
			and (os.time() - challengesData.WeeklyGeneratedAt) / 3600 >= 168
		)
	then
		challengesData.Weekly =
			self:GenerateChallenges(player, ChallengesConfig.ChallengesTypes.Weekly, challengesData.Weekly)
		--Register the challenges generation time
		challengesData.WeeklyGeneratedAt = os.time()
	else
		-- warn("Weekly challenges already exist")
	end
	
	if
		(#challengesData.Daily == 0 and not challengesData.DailyGeneratedAt)
		or (
			#challengesData.Daily < ChallengesConfig.MaxChallengesPerType.Daily
			and (os.time() - challengesData.DailyGeneratedAt or 0) / 3600 >= 24
		)
	then
		challengesData.Daily =
			self:GenerateChallenges(player, ChallengesConfig.ChallengesTypes.Daily, challengesData.Daily)
		--Register the challenges generation time
		challengesData.DailyGeneratedAt = os.time()
	else
		-- warn("Daily challenges already exist")
	end
	--Fire the signal to the client
	self.Client.ChallengesInitialized:Fire(player, challengesData)
end

local function CheckIfChallengeIsAlreadyOnData(challenge, challengesData, challengeToReplace)
	if challenge.name == challengeToReplace.name then
		return true
	end
	for index, _challenge: table in challengesData do
		if _challenge.name == challenge.name then
			return true
		end
	end
	return false
end

function ChallengesService:UpdateChallengeProgression(player: Player, typeOfProgression: string, amount: number)
	--Make sure the player has a challenge that requires destroying objects
	local challengesData = self._dataService:GetKeyValue(player, "Challenges")
	warn(player, typeOfProgression, amount)
	local function UpdateChallengeProgression(challenge, typeOfChallenge: string)
		if challenge.typeOfProgression == typeOfProgression then
			--Check if the challenge has progress if not, set it to 0
			if not challenge.progression then
				challenge.progression = 0
			end
			--Check if the challenge is already completed
			if challenge.isCompleted then
				return
			end
			--Update the challenge progression
			challenge.progression = math.clamp(challenge.progression + amount, 1, challenge.goal)
			--Check if the challenge is already completed
			if challenge.progression >= challenge.goal then
				challenge.isCompleted = true
				--Fire the signal to the client
				self.Client.ChallengeCompleted:Fire(player, challenge, typeOfChallenge)
			end
			--Fire the signal to the client
			self.Client.ChallengeProgressionUpdated:Fire(player, challenge, typeOfChallenge)
			return
		end
	end
	--Daily challenges
	for _, challenge in challengesData.Daily do
		if challenge.typeOfProgression == typeOfProgression then
			UpdateChallengeProgression(challenge, ChallengesConfig.ChallengesTypes.Daily)
		end
	end
	--Weekly challenges
	for _, challenge in challengesData.Weekly do
		if challenge.typeOfProgression == typeOfProgression then
			UpdateChallengeProgression(challenge, ChallengesConfig.ChallengesTypes.Weekly)
		end
	end
end

function ChallengesService:ClaimChallenge(player, challenge: table, challengeType: string)
	local challengesData = self._dataService:GetKeyValue(player, "Challenges")
	--Get the challenge from the challengesData
	for index, _challenge: table in challengesData[challengeType] do
		if _challenge.name == challenge.name then
			--Check if the challenge is already completed
			if _challenge.isCompleted then
				--Reward the player with the challenge reward
				for index, reward: table in _challenge.rewards do
					if reward.rewardType == "BattleCoins" or reward.rewardType == "BattleGems" then
						self._currencyService:AddCurrency(player, reward.rewardType, reward.rewardAmount)
					end
					if reward.rewardType == "BattlepassExp" then
						self._battlepassService:AddBattlepassExperience(player, reward.rewardAmount)
					end
				end
				table.remove(challengesData[challengeType], index)
				--Fire the signal to the client
				self.Client.ChallengeClaimed:Fire(player, challenge, challengeType)
				--Set the new challengesData
				self._dataService:SetKeyValue(player, "Challenges", challengesData)
				return true
			end
		end
	end
end

function ChallengesService.Client:ClaimChallenge(player, challenge, challengeType)
	return self.Server:ClaimChallenge(player, challenge, challengeType)
end

function ChallengesService:ReplaceChallenge(player, challengeToReplace: table, challengeType: string)
	local challengesData = self._dataService:GetKeyValue(player, "Challenges")
	-- Generate a new challenge
	local randomChallengeSelected =
		ChallengesConfig.challenges[challengeType][math.random(1, #ChallengesConfig.challenges[challengeType])]
	--Make sure the challenge isn't already in the challengesData
	local isChallengeOnData =
		CheckIfChallengeIsAlreadyOnData(randomChallengeSelected, challengesData[challengeType], challengeToReplace)
	if isChallengeOnData then
		repeat
			randomChallengeSelected =
				ChallengesConfig.challenges[challengeType][math.random(1, #ChallengesConfig.challenges[challengeType])]
			isChallengeOnData = CheckIfChallengeIsAlreadyOnData(
				randomChallengeSelected,
				challengesData[challengeType],
				challengeToReplace
			)
		until not isChallengeOnData
	end
	--Assign the new challenge
	for index, _challenge in challengesData[challengeType] do
		if _challenge.name == challengeToReplace.name then
			challengesData[challengeType][index] = randomChallengeSelected
		end
	end
	--Fire the signal to the client
	self.Client.ChallengeReplaced:Fire(player, challengeToReplace.name, randomChallengeSelected, challengeType)
end

function ChallengesService.Client:ReplaceChallenge(player, challenge: table, challengeIndex: number)
	self.Server:ReplaceChallenge(player, challenge, challengeIndex)
end

function ChallengesService:GetChallengesForPlayer(player: Player, typeOfChallenges: string)
	local challengesData = self._dataService:GetKeyValue(player, "Challenges")
	return challengesData[typeOfChallenges]
end

function ChallengesService.Client:GetChallengesForPlayer(player: Player, typeOfChallenges: string)
	return self.Server:GetChallengesForPlayer(player, typeOfChallenges)
end

function ChallengesService:KnitInit() end

return ChallengesService
