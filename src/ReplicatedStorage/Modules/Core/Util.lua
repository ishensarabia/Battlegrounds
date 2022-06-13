--!nonstrict

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Conf = require(ReplicatedFirst:WaitForChild("Configurations"):WaitForChild("MainConfiguration"))

local Util = {}

Util._clientFocusTag = "ClientFocus"

function Util.boolToString(val)
	if val then
		return "[true]"
	end

	return "[false]"
end

-- Very inefficient, but provides all available info
function Util.debugPrint(tbl, indent)
	local out = ""

	indent = indent or "  "
	local vStr
	local kStr

	for k,v in pairs(tbl) do
		local t = type(v)

		local kConversionSuccess, kConversionResult = pcall(function() return tostring(k) end)
		if kConversionSuccess then
			kStr = kConversionResult
		else
			kStr = "[" .. type(k) .. "]"
		end

		if t == "table" then
			vStr = string.format("\n%s%s", "", Util.debugPrint(v, indent .. "  "))
		else
			local vConversionSuccess, vConversionResult = pcall(function() return tostring(v) end)
			if vConversionSuccess then
				vStr = vConversionResult
			else
				vStr = "[" .. type(v) .. "]"
			end
		end

		out = string.format("%s%s%s: %s\n", out, indent, kStr, vStr)
	end

	return out
end

function Util.tableToString(tbl, indent)
	local out = ""

	indent = indent or "  "
	local vStr

	for k,v in pairs(tbl) do
		local t = type(v)

		if t == "table" then
			vStr = string.format("\n%s%s", "", Util.tableToString(v, indent .. "  "))

		elseif t == "nil" then
			vStr = "[nil]"

		elseif t == "string" then
			vStr = string.format("\"%s\"", v)

		elseif t == "boolean" then
			vStr = Util.boolToString(v)

		elseif t == "userdata" then
			vStr = "[USERDATA]"

		elseif t == "function" then
			vStr = "[FUNCTION]"

		else
			vStr = v
		end

		k = tostring(k)

		out = string.format("%s%s%s: %s\n", out, indent, k, vStr)
	end

	return out
end

function Util.cloneTable(tbl, dst)
	local new = dst or {}
	
	for k,v in pairs(tbl) do
		local t = type(v)
		
		if t == "table" then
			new[k] = Util.cloneTable(v)
		else
			new[k] = v
		end
	end
	
	return new
end

function Util.newRemoteEvent(name, parent)
	local existing = parent:FindFirstChild(name)

	if existing then
		print(string.format("RemoteEvent %s under %s already exists", name, parent.Name))

		return existing
	end

	local event = Instance.new("RemoteEvent", parent)
	event.Name = name

	return event
end

function Util.isPlayerInGroup(player, groups)
	for _, groupId in ipairs(groups) do
		if player:IsInGroup(groupId) then
			return true
		end
	end
end

function Util.isPlayerIDInTable(player, ids)
	for _, id in ipairs(ids) do
		if player.UserId == id then
			return true
		end
	end
end

function Util.isPlayerBot(player)
	return Util.isPlayerIDInTable(player, Conf.players_as_bots or {}) or 
			string.match(player.Name, Conf.npc_name_prefix) or 
			player.UserId < 0 or 
			string.lower(player.Name) == "player" or 
			string.match(player.Name, Conf.romark_player_name_prefix)
end

function Util.lerp(start, stop, t)
	return start * (1 - t) + stop * t
end

function Util.getClientFocus()
	return CollectionService:GetTagged(Util._clientFocusTag)[1]
end

function Util.setClientFocus(instance)
	if RunService:IsClient() then
		-- Remove any tags
		for _, obj in ipairs(CollectionService:GetTagged(Util._clientFocusTag)) do
			CollectionService:RemoveTag(obj, Util._clientFocusTag)
		end

		-- Tag the specified object
		CollectionService:AddTag(instance, Util._clientFocusTag)
	end
end

function Util.playerIsAlive(player)
	if player and player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			return true
		end
	end
	return false
end

function Util.ancestorHasTag(instance, tag)
	local currentInstance = instance
	while currentInstance do
		if CollectionService:HasTag(currentInstance, tag) then
			return currentInstance
		elseif not currentInstance.Parent then
			return
		else
			currentInstance = currentInstance.Parent
		end
	end

	return
end

function Util.getTableKeys(tbl)
	local keys = {}

	for k in pairs(tbl) do
		table.insert(keys, k)
	end

	return keys
end

function Util.loadCharacter(player, forcedOutfitId)
	local avatars = Conf.avatar_outfits
	local effectiveId = player.UserId
	local outfitId = forcedOutfitId or avatars[(effectiveId % (#avatars - 1)) + 1]

	local playerDesc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
	local desc = Players:GetHumanoidDescriptionFromOutfitId(outfitId)

	-- Load animations from configuration
	for property, value in pairs(Conf.avatar_animations) do
		desc[property] = value
	end

	local emotes = playerDesc:GetEquippedEmotes()
	desc:SetEquippedEmotes(emotes)

	player:LoadCharacterWithHumanoidDescription(desc)

	return outfitId
end

local __friendslistCache
function Util.getRandomFriendFromId(playerId)
	local fallback_id = Conf.outfits.user_id_friends
	local friendId

	-- Playerss:GetFriendsAsync() does a web request and can fail if the request fails
	local success, result = pcall(function()
		return Players:GetFriendsAsync(playerId)
	end)
	
	if success then
		local friendsList = {}
		if not __friendslistCache then
			-- Build a full friends list from friend pages
			while true do
				for _, value in pairs(result:GetCurrentPage()) do
					friendsList[#friendsList + 1] = value
				end
	
				if result.IsFinished then
					break
				else
					result:AdvanceToNextPageAsync()
				end			
			end

			__friendslistCache = friendsList
		else
			friendsList = __friendslistCache
		end

		local random = Random.new()
		friendId = friendsList[random:NextInteger(1, #friendsList)].Id
	else
		warn(string.format("Util.getRandomFriendId() failed. Reason: %s", result))
	end
	
	return friendId or fallback_id
end

function Util.waitForPath(root, path)
	local instance = nil
	
	for _, location in ipairs(path) do
		instance = (instance or root):WaitForChild(location)
	end
	
	return instance
end

function Util.getPath(root, path)
	local instance = nil
	
	for _, location in ipairs(path) do
		instance = (instance or root):FindFirstChild(location)
		if not instance then
			return
		end
	end
	
	return instance
end

function Util.addTags(target, tags)
	if not tags then
		return
	end
	
	local newTags = {}
	
	for _, tag in ipairs(tags) do
		if not CollectionService:HasTag(target, tag) then
			CollectionService:AddTag(target, tag)
			table.insert(newTags, tag)
		end
	end
	
	return newTags
end

function Util._addAgentScripts(agent, scripts, created)
	if not scripts then
		return
	end
	
	for _, path in ipairs(scripts) do
		local src = Util.waitForPath(ReplicatedStorage, path)
		
		if src then
			local scriptInstance = src:Clone()
			scriptInstance.Parent = agent
			scriptInstance.Disabled = false
			
			table.insert(created.scripts, scriptInstance)
		end
	end
end

function Util.addAgentData(agent, data)
	if not data then
		return
	end

	local created = {}
	
	-- CollectionService Tags
	if data.tags then
		created.tags = Util.addTags(agent, data.tags)
	end
	
	-- ValueObjects
	for k, v in pairs(data) do
		if k ~= "tags" and k ~= "scripts" and k ~= "client_scripts" and k ~= "humanoid" then
			local dataType = typeof(v)
			local valueObj = agent:FindFirstChild(k) 
			
			if not valueObj then
				if dataType == "string" then
					valueObj = Instance.new("StringValue")
					
				elseif dataType == "number" then
					valueObj = Instance.new("NumberValue")
					
				elseif dataType == "Vector3" then
					valueObj = Instance.new("Vector3Value")
					
				elseif dataType == "boolean" then
					valueObj = Instance.new("BoolValue")
				end
				
				if valueObj then
					created[k] = valueObj
				end
			end
	
			-- Note:  At this point if the value object already existed, but was a different type, you may get an error here
			if valueObj then
				valueObj.Name = k
				valueObj.Value = v
				valueObj.Parent = agent
			end
		end
	end
	
	-- Scripts
	created.scripts = {}
	
	local scriptList
	if RunService:IsServer() then
		scriptList = data.scripts
	else
		scriptList = data.client_scripts
	end
	
	Util._addAgentScripts(agent, scriptList, created)
	
	return created
end

-- References:
--  - Bias And Gain Are Your Friend
--    http://blog.demofox.org/2012/09/24/bias-and-gain-are-your-friend/
--  - http://demofox.org/biasgain.html
function Util.fbias(t, bias)
   return t / (((1.0 / bias - 2.0) * (1.0 - t)) + 1.0)
end

function Util.fgain(t, gain)
   if t < 0.5 then
      return Util.fbias(t * 2.0, gain) * 0.5
   end

   return Util.fbias(t * 2.0 - 1.0, 1.0 - gain) * 0.5 + 0.5
end


----
return Util
