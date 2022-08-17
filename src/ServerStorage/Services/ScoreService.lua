--Core service
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
--Module dependencies
local dataService = require(ServerStorage.Source.Data.DataService)
--Main
local Knit = require(ReplicatedStorage.Packages.Knit)

local ScoreService = Knit.CreateService {
    Name = "ScoreService",
    Client = {},
}


function ScoreService:KnitStart()
    self.hitSessions = {}
end

function ScoreService:registerDamageDealt(dealer : Player, taker : Player, amount : number)
    --Make sure dealer is not auto-inflicting
    if dealer.UserId == taker.UserId then
        return
    end
    --Make sure the taker is still alive
    if taker.Character.Humanoid.Health < 1  then
        return
    end
    --Detect if there´s a current session and add them to the table
    if self.hitSessions[taker.UserId] == nil then
        warn("No hit session found creating a new one")
        self.hitSessions[taker.UserId] = {}
        self.hitSessions[taker.UserId][dealer.UserId] = amount
    else
        self.hitSessions[taker.UserId][dealer.UserId] = math.clamp(self.hitSessions[taker.UserId][dealer.UserId] + amount, 1, 100)
    end
end

local function damageToBattleCoins(damage : number)
    local convertedNumber = damage * 0.25
    return convertedNumber
end

function ScoreService:rewardHitSession(taker : Player)
    if self.hitSessions[taker.UserId] then
        for damageDealerID, amount in (self.hitSessions[taker.UserId]) do
            local player = Players:GetPlayerByUserId(damageDealerID)
            if player then                
                local damageDealerProfile = dataService:GetProfileData(player)
                damageDealerProfile.BattleCoins += damageToBattleCoins(amount)
            end
        end
    end
end

function ScoreService:KnitInit()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            --On humanoid dead detect damage dealeres to award damage dealers 
            humanoid.Died:Connect(function()
                --reward hit dealers
                self:rewardHitSession(player)
                humanoid:UnequipTools() --Allow for ragdoll and any tool to sync serverside
                for i, tool in pairs(player.Backpack:GetChildren()) do --If you are looking for :Unequip(), see localscript
                    tool:Destroy()
                end
            end)
        end)
    end)
end


return ScoreService
