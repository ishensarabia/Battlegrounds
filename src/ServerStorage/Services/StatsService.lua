local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local StatsService = Knit.CreateService({
	Name = "StatsService",
	Client = {
		StatChanged = Knit.CreateSignal(),
	},
	_GlobalStats = {},
})

local DASH_STAMINA_COST = 39
local MAX_STAMINA = 100

function StatsService:KnitStart()
	local dataService = Knit.GetService("DataService")
	Players.PlayerAdded:Connect(function(player)
		self._GlobalStats[player] = {}
		self._GlobalStats[player].Knockouts = dataService:GetKeyValue(player, "Knockouts")
		player.CharacterAdded:Connect(function(character)
			--Register stats related to the character
			--Register stamina
			character:SetAttribute("Stamina", MAX_STAMINA)
			--Set up stamina regen
			RunService.Heartbeat:Connect(function()
				local stamina = character:GetAttribute("Stamina")
				--Cleanup any stamina related attributes
				if stamina == 0 then
					character:SetAttribute("UsingStamina", false)
				end
				if stamina < MAX_STAMINA and character:GetAttribute("UsingStamina") == false or not character:GetAttribute("UsingStamina") then
					character:SetAttribute("Stamina", math.clamp(stamina + 0.1, 0, MAX_STAMINA))
				end
			end)
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		dataService:SetKeyValue(player, "Knockouts", self._GlobalStats[player].Knockouts)
		self._GlobalStats[player] = nil
	end)
end

function StatsService:KnitInit() end

function StatsService:GetStatValue(player: Player, stat: string)
	local dataService = Knit.GetService("DataService")
	local retrievedStatValue = dataService:GetKeyValue(player, stat)
	return retrievedStatValue
end

function StatsService.Client:GetStatValue(player: Player, stat: string)
	return self.Server:GetStatValue(player, stat)
end

function StatsService:ExecuteAction(player, actionName: string)
	local character = player.Character
	local stamina = character:GetAttribute("Stamina")
	if actionName == "Dash" then
		--Reduce stamina
		if stamina > 0 then
			character:SetAttribute("Stamina", math.clamp(stamina - DASH_STAMINA_COST, 0, MAX_STAMINA))
		end
	end
	--Sprint action
	if actionName == "Sprint" then
		if stamina > 0 then
			character:SetAttribute("Stamina", math.clamp(stamina - 0.1, 0, MAX_STAMINA))
			character:SetAttribute("UsingStamina", true)
		end
	end
	if actionName == "Climb" then
		if stamina > 0 then
			character:SetAttribute("Stamina", math.clamp(stamina - 0.1, 0, MAX_STAMINA))
			character:SetAttribute("UsingStamina", true)
		end
	end
	if actionName == "Climb_Up" then
		if stamina >= 5 then
			character:SetAttribute("Stamina", math.clamp(stamina - 5, 0, MAX_STAMINA))
		end
		character:SetAttribute("UsingStamina", false)
	end
	if actionName == "Slide" then
		if stamina > 0 then
			character:SetAttribute("Stamina", math.clamp(stamina - 0.3, 0, MAX_STAMINA))
			character:SetAttribute("UsingStamina", true)
		end
	end
end

function StatsService:StopAction(player, actionName : string)
	local character = player.Character
	character:SetAttribute("UsingStamina", false)
end

function StatsService.Client:StopAction(player, actionName : string)
	self.Server:StopAction(player, actionName)
end

function StatsService.Client:ExecuteAction(player, actionName: string)
	self.Server:ExecuteAction(player, actionName)
end

function StatsService:AddStat(player: Player, stat: string, amount: number)
	if amount > 0 then
		local statRetrieved = self:GetStatValue(player, stat)
		local newStatValue = statRetrieved + amount
		self._GlobalStats[player] = newStatValue
		self.Client.StatChanged:Fire(player, newStatValue)
	else
		warn("AddStat() no amount set or is less than 0")
	end
end

return StatsService
