local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local StatsService = Knit.CreateService {
    Name = "StatsService",
    Client = {
        StatChanged = Knit.CreateSignal()
    },
    _GlobalStats = {},
}

function StatsService:KnitStart()
    local dataService = Knit.GetService("DataService")
    Players.PlayerAdded:Connect(function(player)
        self._GlobalStats[player] = {}
        self._GlobalStats[player].Knockouts = dataService:GetKeyValue(player, "Knockouts")
    end)
    Players.PlayerRemoving:Connect(function(player)
        self._GlobalStats[player] = nil
    end)
end


function StatsService:KnitInit()
    
end

function StatsService:GetStatValue(player : Player, stat : string)
    -- warn("[Server] Getting stat value for player: " .. player.Name .. " stat: " .. stat)
    local dataService = Knit.GetService("DataService")
    local retrievedStatValue = dataService:GetKeyValue(player, stat)
    -- warn("[Server] Retrieved stat value: " .. retrievedStatValue)
    return retrievedStatValue
end

function StatsService.Client:GetStatValue(player : Player, stat : string)
    return self.Server:GetStatValue(player, stat)
end

function StatsService:AddStat(player : Player, stat : string, amount : number)
    warn("Getting stat from stat service()")
    if amount > 0 then        
        local statRetrieved = self:GetStatValue(player, stat)
        local newStatValue = statRetrieved + amount
        self._GlobalStats[player] = newStatValue
        self.Client.StatChanged:Fire(player, newStatValue)
    else
        warn("AddStat() no amount set or is less than 0")    
    end
end

return StatsService
