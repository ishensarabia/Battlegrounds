local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LevelService = Knit.CreateService({
	Name = "LevelService",
	Client = {
        ExperienceAddedSignal = Knit.CreateSignal(),
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
end

function LevelService:AddExperience(player, amount)
	local currentExperience = self._dataService:GetKeyValue(player, "Experience") or 0
	currentExperience = currentExperience + amount
	self._dataService:SetKeyValue(player, "Experience", currentExperience)
	player:SetAttribute("Experience", currentExperience)
	self:CheckLevelUp(player)
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

-- Modify the CheckLevelUp function to set the Level attribute on the player
function LevelService:CheckLevelUp(player)
	local experience = self._dataService:GetKeyValue(player, "Experience")
	local level = self._dataService:GetKeyValue(player, "Level")
	local experienceToLevelUp = 100 + (level * 50)
	if experience >= experienceToLevelUp then
		self._dataService:incrementIntValue(player, "Level")
		self._dataService:incrementIntValue(player, "Experience", -experienceToLevelUp)
		player:SetAttribute("Level", self._dataService:GetKeyValue(player, "Level"))
		self:CheckLevelUp(player)
	end
end
return LevelService
