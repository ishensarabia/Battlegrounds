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
	Wipeout_Notification = Signal.new(),
	Client = {
		Wipeout_Streak_Notification = Knit.CreateSignal(),
		Wipeout_Notification = Knit.CreateSignal(),
		Assist_Notification = Knit.CreateSignal(),
		Death_Notification = Knit.CreateSignal(),
	},
	Wipeout_Streaks = {
		[5] = "is on a <font color = 'rgb(26, 115, 216)'>RAMPAGE STREAK </font>";
		[10] = "is on a <font color = 'rgb(4, 204, 144)'>DOMINANCE STREAK</font>";
		[15] = "is on an  <font color = 'rgb(255, 32, 20)'>ANNIHILATION STREAK</font>";
		[20] = "is the <font color = 'rgb(72, 55, 104)'>NIGHTMARE</font>";
		[25] = "is the <font color = 'rgb(155, 0, 0)'>CARNAGE</font>";
		[30] = "is the <font color = 'rgb(255, 99, 8)'>CHAOS</font>";
	}
})


function ScoreService:KnitStart()
	self.HitSessions = {}
	self.WipeoutStreaks = {}
	self._leaderboardService = Knit.GetService("LeaderboardService")
	self._challengesService = Knit.GetService("ChallengesService")
end

function ScoreService:RegisterDamageDealt(dealer: Player, taker: Player, amount: number, hitInfo, damageData)
	--Make sure dealer is not auto-inflicting
	if dealer.UserId == taker.UserId then
		return
	end
	--Detect if there´s a current session and add them to the table
	if self.HitSessions[taker.UserId] == nil then
		self.HitSessions[taker.UserId] = {}
		self.HitSessions[taker.UserId][dealer.UserId] = amount
	else
		if self.HitSessions[taker.UserId][dealer.UserId] then
			self.HitSessions[taker.UserId][dealer.UserId] =
				math.clamp(self.HitSessions[taker.UserId][dealer.UserId] + amount, 1, 100)
		else
			self.HitSessions[taker.UserId][dealer.UserId] = amount
		end
	end
	-- Check for headshot
	if hitInfo.part.Name == "Head" then
		self.HitSessions[taker.UserId].headshotDealer = dealer
	end
	self.HitSessions[taker.UserId].lastDamageDealer = dealer
	self.HitSessions[taker.UserId].weaponDealtName = damageData
end

local function damageToBattleCoins(damage: number)
	local convertedNumber = damage * 0.25
	return convertedNumber
end

function ScoreService:RewardHitSession(taker: Player)
	local dataService = Knit.GetService("DataService")
	if self.HitSessions[taker.UserId] then
		for damageDealerID, amount in self.HitSessions[taker.UserId] do
			if type(damageDealerID) == "number" then
				local rewardPlayer = Players:GetPlayerByUserId(damageDealerID)
				if rewardPlayer then
					--Notify the leaderboard service to update the player's score
					self._leaderboardService:UpdatePlayerScore(rewardPlayer, amount)
					local damageDealerDataProfile = dataService:GetProfileData(rewardPlayer)
					damageDealerDataProfile.BattleCoins += damageToBattleCoins(amount)
					self._challengesService:UpdateChallengeProgression(
						rewardPlayer,
						"BattleCoins",
						damageToBattleCoins(amount)
					)
					--Check for headshot
					if
						self.HitSessions[taker.UserId].headshotDealer
						and self.HitSessions[taker.UserId].headshotDealer == rewardPlayer
					then
						warn("Headshot awarded for player : " .. rewardPlayer.Name)
						self._challengesService:UpdateChallengeProgression(rewardPlayer, "HeadshotKnockouts", 1)
						damageDealerDataProfile.BattleCoins += damageToBattleCoins(amount * 0.66)
					end
					-- Check if the player achieved a wipeout streak (e.g., 5, 10, 15, 20)
					if self.WipeoutStreaks[rewardPlayer] then
						self.WipeoutStreaks[rewardPlayer] += 5
					else
						self.WipeoutStreaks[rewardPlayer] = 5
					end
					self.Client.Wipeout_Notification:FireAll(
						amount,
						taker,
						self.HitSessions[taker.UserId].weaponDealtName,
						self.HitSessions[taker.UserId].lastDamageDealer.Name
					)
					warn(self.WipeoutStreaks[rewardPlayer] % 5 )
					
					if self.WipeoutStreaks[rewardPlayer] % 5 == 0  then
						-- Reward the player for the wipeout streak
						local rewardAmount = self.WipeoutStreaks[rewardPlayer] * 10 -- Adjust the reward as needed
						self._leaderboardService:UpdatePlayerScore(rewardPlayer, rewardAmount)
						self._challengesService:UpdateChallengeProgression(rewardPlayer, "WipeoutStreak", 1)
						self.Client.Wipeout_Streak_Notification:FireAll(rewardPlayer.Name, self.Wipeout_Streaks[self.WipeoutStreaks[rewardPlayer]])
					end
				end
			end
		end
	end
end

function ScoreService:GetTopDamageDealer(taker: Player)
	local topDamageDealer = nil
	local damageDealt = 0

	if self.HitSessions[taker.UserId] then
		for damageDealerID, amount in self.HitSessions[taker.UserId] do
			if type(damageDealerID) == "number" then
				if amount > damageDealt then
					damageDealt = amount
					topDamageDealer = Players:GetPlayerByUserId(damageDealerID)
				end
			end
		end
	end

	return topDamageDealer, damageDealt
end

--Get players who dealt damage to the player to notify assist
function ScoreService:RewardAssistPlayers(taker: Player)
	local topDamageDealer, damageDealt = self:GetTopDamageDealer(taker)
	if self.HitSessions[taker.UserId] then
		for damageDealerID, damageAmount in pairs(self.HitSessions[taker.UserId]) do
			if type(damageDealerID) == "number" then
				local player = Players:GetPlayerByUserId(damageDealerID)
				if player and player ~= self.HitSessions[taker.UserId].lastDamageDealer then
					self.Client.Assist_Notification:Fire(player, taker, damageAmount)
				end
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
				--Clear any streaks
				if self.WipeoutStreaks[player] then
					self.WipeoutStreaks[player] = nil
				end
				--notify the player's death
				-- get the player who deliver the final blow (if there's any)
				if player:GetAttribute("KillerID") then
					local killer = Players:GetPlayerByUserId(player:GetAttribute("KillerID"))
					if killer then
						self.Client.Death_Notification:Fire(player, killer)
					end
				end
				--Check if there's any assist
				self:RewardAssistPlayers(player)

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
