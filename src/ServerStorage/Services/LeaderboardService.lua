local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LeaderboardService = Knit.CreateService {
    Name = "LeaderboardService",
    Client = {},
}


function LeaderboardService:KnitStart()
    Players.PlayerAdded:Connect(function(player)
        local leaderboard = Instance.new("Folder")
        leaderboard.Name = "leaderstats"
        leaderboard.Parent = player

        local score = Instance.new("IntValue")
        score.Name = "Score"
        score.Parent = leaderboard

        local rank = Instance.new("IntValue")
        rank.Name = "Rank"
        rank.Parent = leaderboard
    end)
end

function LeaderboardService:UpdatePlayerScore(player, amount)
    local score = player.leaderstats.Score
    score.Value += amount
end

--Get leaderboard function
function LeaderboardService:GetLeaderboard()
    local leaderboard = {}
    for _, player in pairs(Players:GetPlayers()) do
        local score = player.leaderstats.Score
        table.insert(leaderboard, {player = player, score = score.Value})
    end
    table.sort(leaderboard, function(a, b)
        return a.score > b.score
    end)
    return leaderboard
end

--Reset leaderboard function
function LeaderboardService:ResetLeaderboard()
    for _, player in pairs(Players:GetPlayers()) do
        local score = player.leaderstats.Score
        score.Value = 0
    end
end

function LeaderboardService:KnitInit()
    
end


return LeaderboardService
