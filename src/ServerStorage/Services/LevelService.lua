local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local LevelsConfig = require(ReplicatedStorage.Source.Configurations.LevelsConfig)

local LevelService = Knit.CreateService({
	Name = "LevelService",
	Client = {
		ExperienceAddedSignal = Knit.CreateSignal(),
		LevelUpSignal = Knit.CreateSignal(),
		PrestigeSignal = Knit.CreateSignal(),
	},
})

-- Add this to the KnitStart function
function LevelService:KnitStart()
	self._dataService = Knit.GetService("DataService")

	Players.PlayerAdded:Connect(function(player)
		player:GetAttributeChangedSignal("Level"):Connect(function()
			self:HandleLevelChange(player)
		end)
	end)
end

-- Add this function to handle level changes
function LevelService:HandleLevelChange(player)
	local newLevel = player:GetAttribute("Level")
	print("Player " .. player.Name .. "'s level changed to " .. newLevel)
	-- Handle the level change here
	self.Client.LevelUpSignal:Fire(player, newLevel)
end

function LevelService:AddExperience(player, amount)
	--Check if the player is at the max level
	if player:GetAttribute("Level") == LevelsConfig.LEVEL_TO_PRESTIGE then
		self._dataService:SetKeyValue(player, "Experience", 0)
		player:SetAttribute("Experience", 0)
	else
		self.Client.ExperienceAddedSignal:Fire(player, amount)
		local currentExperience = self._dataService:GetKeyValue(player, "Experience") or 0
		currentExperience = currentExperience + amount
		self._dataService:SetKeyValue(player, "Experience", currentExperience)
		player:SetAttribute("Experience", currentExperience)
		self:CheckLevelUp(player)
	end
end

function LevelService:GetLevel(player)
	local level = self._dataService:GetKeyValue(player, "Level")
	return level
end

function LevelService.Client:GetLevel(player)
	return self.Server:GetLevel(player)
end

-- Server-side function
function LevelService:GetExperienceForNextLevel(player)
	local level = self._dataService:GetKeyValue(player, "Level")
	local experienceToLevelUp = 100 + (level * 50)
	return experienceToLevelUp
end

-- Client-side function
function LevelService.Client:GetExperienceForNextLevel(player)
	return self.Server:GetExperienceForNextLevel(player)
end

-- Server-side function
function LevelService:GetExperience(player)
	return self._dataService:GetKeyValue(player, "Experience")
end

-- Client-side function
function LevelService.Client:GetExperience(player)
	return self.Server:GetExperience(player)
end

function LevelService:CheckLevelUp(player)
	local experience = player:GetAttribute("Experience")
	local level = player:GetAttribute("Level")
	if level < LevelsConfig.LEVEL_TO_PRESTIGE then
		local experienceToLevelUp = 100 + (level * 50)
		if experience >= experienceToLevelUp then
			self._dataService:incrementIntValue(player, "Level")
			player:SetAttribute("Level", self._dataService:GetKeyValue(player, "Level"))
			if player:GetAttribute("Level") == LevelsConfig.LEVEL_TO_PRESTIGE then
				player:SetAttribute("Experience", 0) -- Reset experience
				player:SetAttribute("ExperienceToLevelUp", nil) -- Set ExperienceToLevelUp to nil
				self._dataService:SetKeyValue(player, "Experience", 0)
			else
				self._dataService:incrementIntValue(player, "Experience", -experienceToLevelUp)
				player:SetAttribute("Experience", self._dataService:GetKeyValue(player, "Experience"))
				experienceToLevelUp = 100 + (player:GetAttribute("Level") * 50) -- Recalculate experienceToLevelUp after leveling up
				player:SetAttribute("ExperienceToLevelUp", experienceToLevelUp)
				self:CheckLevelUp(player)
			end
		end
	end
end

function LevelService.Client:Prestige(player)
	self.Server:Prestige(player)
end

function LevelService:Prestige(player)
	local level = player:GetAttribute("Level")
	if level == LevelsConfig.LEVEL_TO_PRESTIGE then
		self._dataService:SetKeyValue(player, "Level", 0)
		player:SetAttribute("Level", 0)
		self._dataService:SetKeyValue(player, "Experience", 0)
		player:SetAttribute("Experience", 0)
		self._dataService:SetKeyValue(player, "ExperienceToLevelUp", nil)
		player:SetAttribute("ExperienceToLevelUp", nil)
		self._dataService:incrementIntValue(player, "Prestige")
		player:SetAttribute("Prestige", self._dataService:GetKeyValue(player, "Prestige"))
		self.Client.PrestigeSignal:Fire(player)
	end
end



return LevelService
