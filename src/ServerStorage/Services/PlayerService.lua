--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {},
})

function PlayerService:KnitStart() end

function PlayerService:SpawnCharacter(player: Player)
	player:LoadCharacter()
end

function PlayerService.Client:SpawnCharacter(player)
	return self.Server:SpawnCharacter(player)
end

function PlayerService:KnitInit()
	-- Disable automatic loading of characters
	Players.CharacterAutoLoads = false

	-- Listen for new players joining the game
	Players.PlayerAdded:Connect(function(player)
		-- When a new player joins, listen for when their character is added to the game
		player.CharacterAdded:Connect(function(character)
			-- Register the player's death when their character dies
			character.Humanoid.Died:Connect(function()
				self:RegisterDead(player)
			end)
			
			-- Spawn the player's loadout using the LoadoutService
			Knit.GetService("LoadoutService"):SpawnLoadout(player)
		end)
	end)
end

function PlayerService:RegisterDead(player: Player)
	local dataService = Knit.GetService("DataService")
	dataService:incrementIntValue(player, "Defeats")
end

return PlayerService
