--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local Knit = require(ReplicatedStorage.Packages.Knit)
--Config
local MoneyConfig = require(script.Parent.MoneyConfig)

local CurrencyService = Knit.CreateService{
    Name = "CurrencyService",
    Client = {
        BattleCoinsChanged = Knit.CreateSignal(),
        BattleGemsChanged = Knit.CreateSignal()
    },
    _CurrencyPerPlayer = {},
    _StartingBattleCoins = MoneyConfig.StartingBattleCoins,
}

function CurrencyService:GetCurrencyValue(player : Player, currency : string) : number
    local currencyValueFetched = self._dataService:GetKeyValue(player, currency)
    return currencyValueFetched
end

function CurrencyService:AddMoney(player : Player, amount : number)
    local currentMoney = self:GetCurrencyValue(player) + amount
    if amount > 0 then        
        local newMoney = currentMoney + amount
        self._CurrencyPerPlayer[player] = newMoney
        self.Client.BattleCoinsChanged:Fire(player, newMoney)
    end
end

--Client
function CurrencyService.Client:GetCurrencyValue(player : Player, currency : string) : number
    return self.Server:GetCurrencyValue(player, currency)
end


function CurrencyService:KnitStart()
    self._dataService = Knit.GetService("DataService")
end


return CurrencyService