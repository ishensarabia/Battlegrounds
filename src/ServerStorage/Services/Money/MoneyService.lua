--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local Knit = require(ReplicatedStorage.Packages.Knit)
--Config
local MoneyConfig = require(script.Parent.MoneyConfig)

local MoneyService = Knit.CreateService{
    Name = "MoneyService",
    Client = {
        MoneyChanged = Knit.CreateSignal()
    },
    _MoneyPerPlayer = {},
    _StartingMoney = MoneyConfig.StartingMoney,
}

function MoneyService:GetMoney(player : Player) : number
    local money = self._MoneyPerPlayer[player] or self._StartingMoney
    return money
end

function MoneyService:AddMoney(player : Player, amount : number)
    local currentMoney = self:GetMoney(player) + amount
    if amount > 0 then        
        local newMoney = currentMoney + amount
        self._MoneyPerPlayer[player] = newMoney
        self.Client.MoneyChanged:Fire(player, newMoney)
    end
end

--Client
function MoneyService.Client:GetMoney(player : Player) : number
    return self.Server:GetMoney(player)
end

function MoneyService:KnitStart()
    print("MoneyService Started")

    Players.PlayerRemoving:Connect(function(player)
        self._MoneyPerPlayer[player] = nil
    end)
end

return MoneyService