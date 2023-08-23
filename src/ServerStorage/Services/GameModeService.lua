local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local GameModeService = Knit.CreateService({
	Name = "GameModeService",
	Client = {
		InitializeElectionSignal = Knit.CreateSignal(),
		UpdateVoteCountSignal = Knit.CreateSignal(),
		InitializeGameModeSignal = Knit.CreateSignal(),
	},
})

--Constants
local GAMEMODES = {
	FreeForAll = {
		Time = 300,
		Description = "Kill everyone and be the last one standing!",
	},
	TeamDeathmatch = {
		Time = 30,
		Description = "Kill everyone and be the last one standing!",
	},
}
local TIME_TO_VOTE = 13

GameModeService.currentGameMode = nil

function GameModeService:KnitStart()
	self._leaderboardService = Knit.GetService("LeaderboardService")
	if self.currentGameMode == nil then
		task.wait(10)
		self:InitializeElection()
	end
end

function GameModeService:InitializeElection()
	self._gameModeVotes = {}
	self.Client.InitializeElectionSignal:FireAll(TIME_TO_VOTE)
	task.delay(TIME_TO_VOTE, function()
		self:StartGameMode()
	end)
end

local function getMostVoted(votes)
	local highestVote = 0
	local mostVotedGameMode = nil
	local totalVotes = 0

	for gameMode, voteCount in pairs(votes) do
		totalVotes = totalVotes + voteCount
		if voteCount > highestVote then
			highestVote = voteCount
			mostVotedGameMode = gameMode
		end
	end

	if totalVotes == 0 then
		-- No votes were cast. Pick a random game mode.
		local gameModes = {}
		for gameMode, gameModeInfo in pairs(GAMEMODES) do
			table.insert(gameModes, gameMode)
		end
		local randomIndex = math.random(#gameModes)
		mostVotedGameMode = gameModes[randomIndex]
	end

	return mostVotedGameMode, highestVote
end

function GameModeService:StartGameMode()
	local votes = self:GetVoteCount()
	local mostVotedGameMode, highestVote = getMostVoted(votes)
	if mostVotedGameMode then
		self.currentGameMode = mostVotedGameMode
		self.Client.InitializeGameModeSignal:FireAll(GAMEMODES[mostVotedGameMode].Time)
		--Gamemode loop
		for i = GAMEMODES[mostVotedGameMode].Time, 0, -1 do
			task.wait(1)
		end
		--End gamemode
		self:EndGameMode()
	end
end

function GameModeService:LoadMap() end

--End gamemode function
function GameModeService:EndGameMode()
	self.currentGameMode = nil
	--Get the results of the game mode
	local leaderboard = self._leaderboardService:GetLeaderboard()
	warn(leaderboard)
	self._leaderboardService:ResetLeaderboard()
	--Notify the players of the results
	--Start a new game mode
	self:InitializeElection()
end

function GameModeService:GetVoteCount()
	local votes = {}
	for userID, gameModeName: string in self._gameModeVotes do
		if votes[gameModeName] then
			votes[gameModeName] += 1
		else
			votes[gameModeName] = 1
		end
	end
	return votes
end

function GameModeService:VoteGameMode(player, gameModeName: string)
	self._gameModeVotes[player.UserId] = gameModeName
	self.Client.UpdateVoteCountSignal:FireAll(self:GetVoteCount())
end

--Client vote gamemode
function GameModeService.Client:VoteGameMode(player, gameModeName: string)
	self.Server:VoteGameMode(player, gameModeName)
end

function GameModeService:VoteMap(player, map: string) 
	self._mapsVotes[player.UserId] = map
end

--Client vote map
function GameModeService.Client:VoteMap(player, map : string)
	self.Server:VoteMap()
end

function GameModeService:BeginGameMode(gameMode: table) end

function GameModeService:KnitInit() end

return GameModeService
