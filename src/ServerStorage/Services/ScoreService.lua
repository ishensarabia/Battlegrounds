--Core service
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
--Module dependencies
--Main
local Knit = require(ReplicatedStorage.Packages.Knit)

local ScoreService = Knit.CreateService({
	Name = "ScoreService",
	KO_Notification = Signal.new(),
	Client = {
		KO_Notification = Knit.CreateSignal(),
		Death_Notification = Knit.CreateSignal(),
	},
})

function ScoreService:KnitStart()
	self.HitSessions = {}
end

function ScoreService:RegisterDamageDealt(dealer: Player, taker: Player, amount: number)
	--Make sure dealer is not auto-inflicting
	if dealer.UserId == taker.UserId then
		return
	end
	--Detect if there´s a current session and add them to the table
	if self.HitSessions[taker.UserId] == nil then
		self.HitSessions[taker.UserId] = {}
		self.HitSessions[taker.UserId][dealer.UserId] = amount
	else
		self.HitSessions[taker.UserId][dealer.UserId] =
			math.clamp(self.HitSessions[taker.UserId][dealer.UserId] + amount, 1, 100)
	end
end

local function damageToBattleCoins(damage: number)
	local convertedNumber = damage * 0.25
	return convertedNumber
end

function ScoreService:RewardHitSession(taker: Player)
	local dataService = Knit.GetService("DataService")
	if self.HitSessions[taker.UserId] then
		for damageDealerID, amount in self.HitSessions[taker.UserId] do
			local player = Players:GetPlayerByUserId(damageDealerID)
			if player then
				local damageDealerDataProfile = dataService:GetProfileData(player)
				damageDealerDataProfile.BattleCoins += damageToBattleCoins(amount)
			end
		end
	end
end 

function ScoreService:GetTopDamageDealer(taker: Player)
	local topDamageDealer = nil
	local damageDealt = 0

	if self.HitSessions[taker.UserId] then
		for damageDealerID, amount in pairs(self.HitSessions[taker.UserId]) do
			if amount > damageDealt then
				damageDealt = amount
				topDamageDealer = Players:GetPlayerByUserId(damageDealerID)
			end
		end
	end

	return topDamageDealer, damageDealt
end

function ScoreService:KnitInit()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			--On humanoid dead detect damage dealeres to award damage dealers
			humanoid.Died:Connect(function()
				--reward hit dealers
				self:RewardHitSession(player)
				--Register the player's who's responsible for the kill
				local topDamageDealer, damageDealt = self:GetTopDamageDealer(player)
				if topDamageDealer then
					--notify the killer about the kill and the player's death
					self.Client.KO_Notification:Fire(topDamageDealer, damageDealt, player)
					player:SetAttribute("KillerID", topDamageDealer.UserId)
					--notify the player's death
					self.Client.Death_Notification:Fire(player, topDamageDealer)
				end
				humanoid:UnequipTools() --Allow for ragdoll and any tool to sync serverside
				for i, tool in (player.Backpack:GetChildren()) do --If you are looking for :Unequip(), see localscript
					tool:Destroy()
				end
				--Cleanup the score session
				self.HitSessions[player.UserId] = nil
			end)
		end)
	end)
	--Cleanup the score session
	Players.PlayerRemoving:Connect(function(player)
		if self.HitSessions[player] then
			self.HitSessions[player] = nil
		end
	end)
end

return ScoreService
