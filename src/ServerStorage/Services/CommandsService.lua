local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local CommandsConfig = require(ReplicatedStorage.Source.Configurations.CommandsConfig)
local Knit = require(ReplicatedStorage.Packages.Knit)

local CommandsService = Knit.CreateService({
	Name = "CommandsService",
	Client = {},
})

function CommandsService:KnitStart()
	--Create the text chat commands
	for commandName: string, commandData: table in CommandsConfig.commands do
		local textChatCommand = Instance.new("TextChatCommand")
		textChatCommand.Name = commandName
		textChatCommand.PrimaryAlias = commandData.alias
		textChatCommand.SecondaryAlias = commandData.secondaryAlias

		textChatCommand.Parent = TextChatService

		textChatCommand.Triggered:Connect(function(textSource : TextSource, message : string)
			local player = Players:GetPlayerByUserId(textSource.UserId)
			if not RunService:IsStudio() then
				local canExecuteCommand = self:CheckAccessLevel(textSource, commandData)
				if not canExecuteCommand then
					return
				end
			end
			if commandData == CommandsConfig.commands.AddExperience then
				self:AddExperienceCommand(player, message)
			end
			if commandData == CommandsConfig.commands.AddBattlepassExperience then
				self:AddBattlepassExperienceCommand(player, message)
			end
			if commandData == CommandsConfig.commands.WipeData then
				self:WipeDataCommand(player, message)
			end
			if commandData == CommandsConfig.commands.ApplyDamage then
				self:ApplyDamageCommand(player, message)
			end
			if commandData == CommandsConfig.commands.AddSkin then
				self:AddSkinCommand(player, message)
			end
			if commandData == CommandsConfig.commands.UpdateChallengeProgresion then
				self:UpdateChallengeProgresionCommand(player, message)
			end
			if commandData == CommandsConfig.commands.AddCurrency then
				self:AddCurrencyCommand(player, message)
			end

		end)
	end
end

function CommandsService:AddCurrencyCommand(player, message)
	local splitMessage = string.split(message, " ")
	local targetPlayer = player
	local currencyType = splitMessage[2]
	local currencyToAdd = tonumber(splitMessage[3])

	-- Check if the second parameter is a username
	if splitMessage[4] then
		local playerID = Players:GetUserIdFromNameAsync(splitMessage[4])
		targetPlayer = Players:GetPlayerByUserId(playerID)
	end
	Knit.GetService("CurrencyService"):AddCurrency(targetPlayer, currencyType, currencyToAdd)
end

function CommandsService:UpdateChallengeProgresionCommand(player, message)
	local splitMessage = string.split(message, " ")
	local targetPlayer = player
	local challengeName = splitMessage[2]
	local progressionToAdd = tonumber(splitMessage[3])

	-- Check if the second parameter is a username
	if splitMessage[4] then
		local playerID = Players:GetUserIdFromNameAsync(splitMessage[4])
		targetPlayer = Players:GetPlayerByUserId(playerID)
	end
	Knit.GetService("ChallengesService"):UpdateChallengeProgression(targetPlayer, challengeName, progressionToAdd)
end

function CommandsService:AddExperienceCommand(player, message)
	local splitMessage = string.split(message, " ")
	local targetPlayer = player
	local experienceToAdd

	-- Check if the second parameter is a number (experience to add)
	if tonumber(splitMessage[2]) then
		experienceToAdd = tonumber(splitMessage[2])
	else
		-- If it's not a number, assume it's a username
		local playerID = Players:GetUserIdFromNameAsync(splitMessage[2])
		targetPlayer = Players:GetPlayerByUserId(playerID)

		-- Check if the third parameter is a number (experience to add)
		if not tonumber(splitMessage[3]) then
			return
		end
		experienceToAdd = tonumber(splitMessage[3])
	end
	Knit.GetService("LevelService"):AddExperience(targetPlayer, experienceToAdd)
end

function CommandsService:AddBattlepassExperienceCommand(player, message)
	local splitMessage = string.split(message, " ")
	local targetPlayer = player
	local experienceToAdd

	-- Check if the second parameter is a number (experience to add)
	if tonumber(splitMessage[2]) then
		experienceToAdd = tonumber(splitMessage[2])
	else
		-- If it's not a number, assume it's a username
		local playerID = Players:GetUserIdFromNameAsync(splitMessage[2])
		targetPlayer = Players:GetPlayerByUserId(playerID)

		-- Check if the third parameter is a number (experience to add)
		if not tonumber(splitMessage[3]) then
			return
		end
		experienceToAdd = tonumber(splitMessage[3])
	end
	Knit.GetService("BattlepassService"):AddBattlepassExperience(targetPlayer, experienceToAdd)
end

function CommandsService:AddSkinCommand(player, message)
	local splitMessage = string.split(message, " ")
	local targetPlayer = player
	local skinName = splitMessage[2]

	-- Check if the second parameter is a username
	if splitMessage[3] then
		local playerID = Players:GetUserIdFromNameAsync(splitMessage[3])
		targetPlayer = Players:GetPlayerByUserId(playerID)
	end
	Knit.GetService("DataService"):AddSkin(targetPlayer, skinName)
end

function CommandsService:WipeDataCommand(player, message)
	local splitMessage = string.split(message, " ")
	local targetPlayer = player

	-- Check if the second parameter is a username
	if splitMessage[2] then
		local playerID = Players:GetUserIdFromNameAsync(splitMessage[2])
		targetPlayer = Players:GetPlayerByUserId(playerID)
	end
	
	Knit.GetService("DataService"):WipeData(targetPlayer)

end

function CommandsService:ApplyDamageCommand(player, message)
	local splitMessage = string.split(message, " ")
	local targetPlayer = player
	local damageToApply

	-- Check if the second parameter is a username
	if not tonumber(splitMessage[2]) then
		local playerID = Players:GetUserIdFromNameAsync(splitMessage[2])
		targetPlayer = Players:GetPlayerByUserId(playerID)
		damageToApply = splitMessage[3] or 10
	else
		damageToApply = splitMessage[2]
	end
	targetPlayer.Character.Humanoid:TakeDamage(damageToApply)
end

function CommandsService:CheckAccessLevel(player, commandData)
	local playerAccessLevel = "User"
	for accessLevelName: string, accessLevelData: table in CommandsConfig.accessLevels do
		if accessLevelData.userIDs and table.find(accessLevelData.userIDs, player.UserId) then
			playerAccessLevel = accessLevelName
			break
		end
		-- if accessLevelData.groupIDs then
		-- 	for _, groupID in (accessLevelData.groupIDs) do
		-- 		if player:IsInGroup(groupID) then
		-- 			playerAccessLevel = accessLevelName
		-- 			break
		-- 		end
		-- 	end
		-- end
	end

	if playerAccessLevel == "Owner" then
		return true
	end

	if playerAccessLevel == commandData.accessLevel then
		return true
	end

	return false
end

function CommandsService:KnitInit() end

return CommandsService
