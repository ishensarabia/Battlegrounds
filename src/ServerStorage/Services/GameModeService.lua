local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Utilities
local TerrainSaveLoad = require(ServerStorage.TerrainSaveLoad)

local GameModeService = Knit.CreateService({
	Name = "GameModeService",
	Client = {
		InitializeElectionSignal = Knit.CreateSignal(),
		UpdateVoteCountSignal = Knit.CreateSignal(),
		InitializeGameModeSignal = Knit.CreateSignal(),
		EndGameSignal = Knit.CreateSignal(),
	},
})

--Constants
local GAMEMODES = {
	FreeForAll = {
		Time = 1200,
		Description = "Kill everyone and be the last one standing!",
	},
	TeamDeathmatch = {
		Time = 10,
		Description = "Kill everyone and be the last one standing!",
	},
}
local MAPS = ServerStorage.Maps
local TIME_TO_VOTE = 13

GameModeService.currentGameMode = nil

function GameModeService:KnitStart()
	self._leaderboardService = Knit.GetService("LeaderboardService")
	self._challengesService = Knit.GetService("ChallengesService")

	if self.currentGameMode == nil then
		task.wait(10)
		self:InitializeElection()
	end
end

function GameModeService:InitializeElection()
	self._gameModeVotes = {}
	self._mapsVotes = {}
	self.Client.InitializeElectionSignal:FireAll(TIME_TO_VOTE)
	task.delay(TIME_TO_VOTE, function()
		self:StartGameMode()
	end)
end

--TODO: set up the type of vote
local function getMostVoted(votes, typeOfVote: string)
	local highestVote = 0
	local mostVotedOption = nil
	local totalVotes = 0

	for option, voteCount in pairs(votes) do
		totalVotes = totalVotes + voteCount
		if voteCount > highestVote then
			highestVote = voteCount
			mostVotedOption = option
		end
	end

	if typeOfVote == "Map" then
		if totalVotes == 0 then
			-- No votes were cast. Pick a random game mode.
			local maps = {}
			for index, mapFolder in (MAPS:GetChildren()) do
				if mapFolder:IsA("Folder") then
					table.insert(maps, mapFolder.Name)
				end
			end
			local randomIndex = math.random(#maps)
			mostVotedOption = maps[randomIndex]
		end
	end

	if typeOfVote == "GameMode" then
		if totalVotes == 0 then
			-- No votes were cast. Pick a random game mode.
			local gameModes = {}
			for gameMode, gameModeInfo in GAMEMODES do
				table.insert(gameModes, gameMode)
			end
			local randomIndex = math.random(#gameModes)
			mostVotedOption = gameModes[randomIndex]
		end
	end
	return mostVotedOption, highestVote
end

function GameModeService:StartGameMode()
	--Get most voted gameMode
	local gameModeVotes = self:GetVoteCount("GameMode")
	local mostVotedGameMode, highestVote = getMostVoted(gameModeVotes, "GameMode")
	if mostVotedGameMode then
		--Get the most voted map
		local mapVotes = self:GetVoteCount("Map")
		local mostVotedMap, highestVote = getMostVoted(mapVotes, "Map")
		if mostVotedMap then
			-- self:LoadMap(mostVotedMap)
		end
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

function GameModeService:LoadMap(map: string)
	--Get the map folder
	local selectedMap: Folder = MAPS[map]:Clone()
	--Clean any previous map
	workspace.Map:ClearAllChildren()
	--Set the parent
	selectedMap.Parent = workspace.Map
	selectedMap.Cutscene.Parent = workspace.Map
	--Check if there's any terrain and load it
	local terrainRegion = selectedMap:FindFirstChildWhichIsA("TerrainRegion")
	if terrainRegion then
		TerrainSaveLoad.Load(terrainRegion)
	else
		workspace.Terrain:Clear()
	end
end

--End gamemode function
function GameModeService:EndGameMode()
	self.currentGameMode = nil
	--Get the results of the game mode
	local leaderboard = self._leaderboardService:GetLeaderboard()
	--Get top 3 players
	local topPlayers = self._leaderboardService:GetTopPlayers(3)
	--Display the top players
	self.Client.EndGameSignal:FireAll(topPlayers)
	for index, playerScoreData in topPlayers do
		-- warn(playerScoreData)
		self._challengesService:UpdateChallengeProgression(playerScoreData.player, "TopPlayers", 1)
	end
	self._leaderboardService:ResetLeaderboard()
	--Notify the players of the results
	--Start a new game mode
	task.delay(3, function()
		for index, player in Players:GetPlayers() do
			if player.Character then
				player.Character.Humanoid:TakeDamage(100)
			end
		end
	end)
	task.delay(9, function()
		self:InitializeElection()
	end)
end

function GameModeService:GetVoteCount(typeOfVote: string)
	local votes = {}
	if typeOfVote == "GameMode" then
		for userID, gameModeName: string in self._gameModeVotes do
			if votes[gameModeName] then
				votes[gameModeName] += 1
			else
				votes[gameModeName] = 1
			end
		end
	end
	if typeOfVote == "Map" then
		for userID, mapName: string in self._mapsVotes do
			if votes[mapName] then
				votes[mapName] += 1
			else
				votes[mapName] = 1
			end
		end
	end
	return votes
end

function GameModeService:VoteGameMode(player, gameModeName: string)
	self._gameModeVotes[player.UserId] = gameModeName
	self.Client.UpdateVoteCountSignal:FireAll(self:GetVoteCount("GameMode"), "GameMode")
end

--Client vote gamemode
function GameModeService.Client:VoteGameMode(player, gameModeName: string)
	self.Server:VoteGameMode(player, gameModeName)
end

function GameModeService:VoteMap(player, map: string)
	self._mapsVotes[player.UserId] = map
	self.Client.UpdateVoteCountSignal:FireAll(self:GetVoteCount("Map"), "Map")
end

--Client vote map
function GameModeService.Client:VoteMap(player, map: string)
	self.Server:VoteMap(player, map)
end

function GameModeService:BeginGameMode(gameMode: table) end

function GameModeService:KnitInit() end

return GameModeService
