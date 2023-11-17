local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LeaderboardService = Knit.CreateService({
	Name = "LeaderboardService",
	Client = {},
})

function LeaderboardService:KnitStart()
	Players.PlayerAdded:Connect(function(player)
		local leaderboard = Instance.new("Folder")
		leaderboard.Name = "leaderstats"
		leaderboard.Parent = player

		local level = Instance.new("IntValue")
		level.Name = "Level"
		level.Value = Knit.GetService("DataService"):GetKeyValue(player, "Level")
		player:SetAttribute("Level", level.Value)
		level.Parent = leaderboard


		local score = Instance.new("IntValue")
		score.Name = "Score"
		score.Parent = leaderboard
	end)
end

--Update the player scoare
function LeaderboardService:UpdatePlayerScore(player, amount)
	local score = player.leaderstats.Score
	score.Value += amount
end

--Get leaderboard function
function LeaderboardService:GetLeaderboard()
	local leaderboard = {}
	for _, player in (Players:GetPlayers()) do
		local score = player.leaderstats.Score
		table.insert(leaderboard, { player = player, score = score.Value })
	end
	table.sort(leaderboard, function(a, b)
		return a.score > b.score
	end)
	return leaderboard
end

--Reset leaderboard function
function LeaderboardService:ResetLeaderboard()
	for _, player in (Players:GetPlayers()) do
		local score = player.leaderstats.Score
		score.Value = 0
	end
end

-- Function to get the top players (you can adjust the 'count' parameter as needed)
function LeaderboardService:GetTopPlayers(count)
	local leaderboard = self:GetLeaderboard()
	local topPlayers = {}

	-- Take the top 'count' players from the sorted leaderboard table
	for i = 1, count do
		if leaderboard[i] then
			table.insert(topPlayers, leaderboard[i])
		else
			break
		end
	end

	return topPlayers
end

function LeaderboardService:KnitInit() end

return LeaderboardService
