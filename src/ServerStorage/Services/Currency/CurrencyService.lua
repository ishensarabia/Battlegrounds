--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Assets
local Weapons = ReplicatedStorage.Weapons
--Enums
local CurrenciesEnum = require(ReplicatedStorage.Source.Enums.CurrenciesEnum)
-- Currency types
export type Currency = "battleCoins" | "battleGems" | "robux";



local CurrencyService = Knit.CreateService({
	Name = "CurrencyService",
	Client = {
		CurrencyChanged = Knit.CreateSignal(),
	},
	_CurrencyPerPlayer = {},
})

function CurrencyService:GetCurrencyValue(player: Player, currency: string): number
	local currencyValueFetched = self._dataService:GetKeyValue(player, currency)
	return currencyValueFetched
end

function CurrencyService:AddCurrency(player: Player, currencyType: Currency, amount: number)
	warn()
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

function CurrencyService:PurchasePrestigeWeapon(player: Player, weaponName: string)
	local weaponInstance = Weapons[weaponName]
	local price = weaponInstance:GetAttribute("Price")
	local currency = weaponInstance:GetAttribute("Currency")
	local playerCurrency = self:GetCurrency(player, currency)
	if playerCurrency >= price then
		self:RemoveCurrency(player, currency, price)
		self._dataService:AddWeapon(player, weaponName)
		return true, "Weapon purchased successfully"
	else
		return false, "Not enough Battlecoins to purchase this weapon"
	end
end

--PurchaseWeapon 
function CurrencyService:PurchaseWeapon(player: Player, weaponName: string, isEarlyBuy: boolean)
    local weaponInstance = Weapons[weaponName]
	
    local price = weaponInstance:GetAttribute("Price")
    local earlyPrice = weaponInstance:GetAttribute("EarlyPrice")
	local currency = weaponInstance:GetAttribute("Currency")
	local earlyCurrency = weaponInstance:GetAttribute("EarlyCurrency")


    if weaponInstance then
		--Note: Implement later on different currencies
		if isEarlyBuy then
			local playerCurrency = self:GetCurrency(player, earlyCurrency)
			if playerCurrency >= earlyPrice then
				warn("Early buy successful")
				self:RemoveCurrency(player, earlyCurrency, earlyPrice)
				self._dataService:UnlockWeapon(player, weaponName)
				return true, "Weapon purchased successfully"
			else
				return false, "Not enough Battlecoins to purchase this weapon"
			end
		else
			local playerCurrency = self:GetCurrency(player, currency)
			if playerCurrency >= price then
				warn("Buy successful")
				self:RemoveCurrency(player, currency, price)
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
--PurchaseWeapon Client
function CurrencyService.Client:PurchaseWeapon(player: Player, weaponName: string)
	return self.Server:PurchaseWeapon(player, weaponName)
end

--Get currency
function CurrencyService:GetCurrency(player: Player, currencyType: Currency)
	local currentCurrency = self._dataService:GetKeyValue(player, currencyType)
	return currentCurrency
end

--[Client] Get currency
function CurrencyService.Client:GetCurrency(player: Player, currencyType: string)
	return self.Server:GetCurrency(player, currencyType)
end


--Client
function CurrencyService.Client:GetCurrencyValue(player: Player, currency: Currency): number
	return self.Server:GetCurrencyValue(player, currency)
end

function CurrencyService:KnitStart()
	self._dataService = Knit.GetService("DataService")
end

return CurrencyService
