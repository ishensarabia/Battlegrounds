local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local DailyRewardsService = Knit.CreateService {
    Name = "DailyRewardsService",
    Client = {},
}

local rewards = {
    {ItemId = "Coins", Amount = 100},
    {ItemId = "Gems", Amount = 10},
    {ItemId = "ExclusiveItem", Amount = 1},
    -- Add as many days as you like
}

function DailyRewardsService:KnitStart()
    self._dataService = Knit.GetService("DataService")
end


function DailyRewardsService:KnitInit()
    
end



function DailyRewardsService:CanClaimReward(player)
    local LastDailyReward = self._dataService:GetKeyValue(player, "LastDailyReward")
    
    local now = os.time()
    return os.difftime(now, LastDailyReward   ) >= (24 * 60 * 60) -- 24 hours
end

function DailyRewardsService:ClaimReward(player)
    if not self:CanClaimReward(player) then
        return false, "You have already claimed your daily reward."
    end
    
    local data = self:GetPlayerData(player)
    data.ClaimStreak = (data.ClaimStreak or 0) + 1
    local rewardIndex = math.min(data.ClaimStreak, #rewards)
    local reward = rewards[rewardIndex]
    
    -- Logic to give the reward to the player
    -- e.g., increment player's inventory or currency
    
    data.LastClaim = os.time()
    self:SetPlayerData(player, data)
    
    return true, "Reward claimed successfully!", reward
end

return DailyRewardsService
