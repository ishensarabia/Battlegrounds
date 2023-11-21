--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Config
local MoneyConfig = require(script.Parent.MoneyConfig)
local Weapons = ReplicatedStorage.Weapons

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
	local currentCurrency = self._dataService:GetKeyValue(player, currencyType)
	if amount > 0 then
		currentCurrency += amount
		self._dataService:SetKeyValue(player, currencyType, currentCurrency)
		self.Client.CurrencyChanged:Fire(player, currencyType, currentCurrency)
		return true
	end
end

--Remove currency
function CurrencyService:RemoveCurrency(player: Player, currencyType: string, amount: number)
	local currentCurrency = self._dataService:GetKeyValue(player, currencyType)
	if amount > 0 then
		currentCurrency -= amount
		self._dataService:SetKeyValue(player, currencyType, currentCurrency)
		self.Client.CurrencyChanged:Fire(player, currencyType, currentCurrency)
		return true
	end
end
--BuyWeapon 
function CurrencyService:BuyWeapon(player: Player, weaponName: string, isEarlyBuy: boolean)
    local weaponInstance = Weapons[weaponName]
	
    local price = weaponInstance:GetAttribute("Price")
    local earlyPrice = weaponInstance:GetAttribute("EarlyPrice")


    if weaponInstance then
        local playerCurrency = self:GetCurrency(player, "BattleCoins")
		if isEarlyBuy then
			if playerCurrency >= earlyPrice then
				self:RemoveCurrency(player, "BattleCoins", earlyPrice)
				self._dataService:UnlockWeapon(player, weaponName)
				return true, "Weapon purchased successfully"
			else
				return false, "Not enough Battlecoins to purchase this weapon"
			end
		else
			if playerCurrency >= price then
				self:RemoveCurrency(player, "BattleCoins", price)
				self._dataService:UnlockWeapon(player, weaponName)
				return true, "Weapon purchased successfully"
			else
				return false, "Not enough Battlecoins to purchase this weapon"
			end	
		end
    else
        return false, "Weapon does not exist"
    end
end
--BuyWeapon Client
function CurrencyService.Client:BuyWeapon(player: Player, weaponName: string)
	return self.Server:BuyWeapon(player, weaponName)
end

--Get currency
function CurrencyService:GetCurrency(player: Player, currencyType: string)
	local currentCurrency = self._dataService:GetKeyValue(player, currencyType)
	warn(currentCurrency)
	return currentCurrency
end

--[Client] Get currency
function CurrencyService.Client:GetCurrency(player: Player, currencyType: string)
	return self.Server:GetCurrency(player, currencyType)
end


--Client
function CurrencyService.Client:GetCurrencyValue(player: Player, currency: string): number
	return self.Server:GetCurrencyValue(player, currency)
end

function CurrencyService:KnitStart()
	self._dataService = Knit.GetService("DataService")
end

return CurrencyService
