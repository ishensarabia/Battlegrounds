--Core service
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--Module dependencies
--Main
local Knit = require(ReplicatedStorage.Packages.Knit)

local ScoreService = Knit.CreateService({
	Name = "ScoreService",
	Client = {},
})

function ScoreService:KnitStart()
	self.HitSessions = {}
end

function ScoreService:RegisterDamageDealt(dealer: Player, taker: Player, amount: number)
	--Make sure dealer is not auto-inflicting
	if dealer.UserId == taker.UserId then
		return
	end
	--Make sure the taker is still alive
	if taker.Character.Humanoid.Health < 1 then
		return
	end
	--Detect if there´s a current session and add them to the table
	if self.HitSessions[taker.UserId] == nil then
		warn("No hit session found creating a new one")
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
				self:RewardHitSession(player)
				humanoid:UnequipTools() --Allow for ragdoll and any tool to sync serverside
				for i, tool in (player.Backpack:GetChildren()) do --If you are looking for :Unequip(), see localscript
					tool:Destroy()
				end
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
