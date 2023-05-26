--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Config
local MoneyConfig = require(script.Parent.MoneyConfig)

local CurrencyService = Knit.CreateService({
	Name = "CurrencyService",
	Client = {
		CurrencyChanged = Knit.CreateSignal(),
	},
	_CurrencyPerPlayer = {},
	_StartingBattleCoins = MoneyConfig.StartingBattleCoins,
})

function CurrencyService:GetCurrencyValue(player: Player, currency: string): number
	local currencyValueFetched = self._dataService:GetKeyValue(player, currency)
	return currencyValueFetched
end

function CurrencyService:AddCurrency(player: Player, currencyType: string, amount: number)
    warn(player, currencyType, amount)
	local currentCurrency = self._dataService:GetKeyValue(player, currencyType)
	if amount > 0 then
		local newCurrency = currentCurrency + amount
		self.Client.CurrencyChanged:Fire(player, currencyType, newCurrency)
	end
end

--Client
function CurrencyService.Client:GetCurrencyValue(player: Player, currency: string): number
	return self.Server:GetCurrencyValue(player, currency)
end

function CurrencyService:KnitStart()
	self._dataService = Knit.GetService("DataService")
end

return CurrencyService
